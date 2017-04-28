.. _section_http:

Using rasa NLU as a HTTP server
===============================

.. note:: Before you can use the server, you need to train a model! See :ref:`training_your_model`

The HTTP api exists to make it easy for non-python projects to use rasa NLU, and to make it trivial for projects currently using {wit,LUIS,api}.ai to try it out.

Running the server
------------------
You can run a simple http server that handles requests using your models with (single threaded)

.. code-block:: bash

    $ python -m rasa_nlu.server -c config_spacy.json --server_model_dirs=./model_YYYYMMDD-HHMMSS

If your server needs to handle more than one request at a time, you can use any WSGI server to run the rasa NLU server. Using gunicorn this looks like this:

.. code-block:: bash

    $ gunicorn -w 4 --threads 12 -k gevent -b 127.0.0.1:5000 rasa_nlu.server

This will start a server with four processes and 12 threads. Since there is no standard way to pass command line arguments to the server, all your configuration
options need to be placed in your configuration file (including the ``server_model_dirs``!). You can set the location of the configuration file using environment
variables, otherwise the default configuration from ``config.json`` will be loaded.


Emulation
---------
rasa NLU can 'emulate' any of these three services by making the ``/parse`` endpoint compatible with your existing code.
To activate this, either add ``'emulate' : 'luis'`` to your config file or run the server with ``-e luis``.
For example, if you would normally send your text to be parsed to LUIS, you would make a ``GET`` request to

``https://api.projectoxford.ai/luis/v2.0/apps/<app-id>?q=hello%20there``

in luis emulation mode you can call rasa by just sending this request to 

``http://localhost:5000/parse?q=hello%20there``

any extra query params are ignored by rasa, so you can safely send them along. 


Endpoints
---------

``POST /parse`` (no emulation)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

you must POST data in this format ``'{"q":"<your text to parse>"}'``, you can do this with

.. code-block:: bash

    $ curl -XPOST localhost:5000/parse -d '{"q":"hello there"}'


``POST /train``
^^^^^^^^^^^^^^^

you can post your training data to this endpoint to train a new model. 
this starts a separate process which you can monitor with the ``/status`` endpoint. 

.. code-block:: bash

    $ curl -XPOST localhost:5000/train -d @data/examples/rasa/demo-rasa.json


``GET /status``
^^^^^^^^^^^^^^^

this checks if there is currently a training process running (you can only run one at a time).
also returns a list of available models the server can use to fulfill ``/parse`` requests.

.. code-block:: bash

    $ curl localhost:5000/status | python -mjson.tool
    {
      "training" : False
      "models" : []
    }

.. _section_auth:

Authorization
-------------
To protect your server, you can specify a token in your rasa NLU configuration, e.g. by adding ``"token" : "12345"`` to your config file, or by setting the ``RASA_TOKEN`` environment variable.
If set, this token must be passed as a query parameter in all requests, e.g. :

.. code-block:: bash

    $ curl localhost:5000/status?token=12345

.. _section_http_config:

Serving Multiple Apps
---------------------

Depending on your choice of backend, rasa NLU can use quite a lot of memory.
So if you are serving multiple models in production, you want to serve these
from the same process & avoid duplicating the memory load.

.. note::
    Although this saves the backend from loading the same backend twice, it still needs to load one set of
    word vectors (which make up most of the memor consumption) per language and backend.

You can use the multi-tenancy mode by replacing the ``server_model_dirs`` config
variable with a json object describing the different models.

For example, if you have a restaurant bot and a hotel bot, your configuration might look like this:


.. code-block:: json

    {
      "server_model_dirs": {
        "hotels" : "./model_XXXXXXX",
        "restaurants" : "./model_YYYYYYY"
      }
    }


You then pass an extra ``model`` parameter in your calls to ``/parse`` to specify which one to use:

.. code-block:: console

    $ curl 'localhost:5000/parse?q=hello&model=hotels'

or

.. code-block:: console

    $ curl -XPOST localhost:5000/parse -d '{"q":"I am looking for Chinese food", "model": "restaurants"}'

If one of the models is named ``default``, it will be used to serve requests missing a ``model`` parameter.
If no model is named ``default`` requests without a model parameter will be rejected.
