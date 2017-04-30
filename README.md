# Chat Robot

### Statement
The goal of Chat Robot is to create a chat robot using machine learning. It is a single page web app where users can talk to the chat robot through a front end interface, and it can learn things about them. The most interesting aspect of Chat Robot is the machine learning. Saurabh and I are personally interested in machine learning, and would like to learn more about it.

### Analysis
- recursion was necessary. we needed to loop through data, and select or alter it.
- higher order functions were used such as map, and filter.
- Object-Orientation: We took class concepts two steps further and implemented objects with superclasses, member variables and member functions. We also used `set!` to modify values of object properties
- Pair Accessors: We used multiple `car`, `cdar` and similar accessors to retrieve elements from list structures


### Data Sets or other Source Materials
Since machine-learning is a significant part of this project, it is essential for us to "feed" the bot with data sets that it can use to make important decisions. We initially considered looking for data sets on the web. However, we decided to create data ourselves, as it was simpler and quicker.

Since we are wrote the data ourselves, we did not encounter an issue where our bot was unable to "understand" it.

We initally planned to have two types of data set formats: 1) one for NLP (Natural Language Processing) and 2) one for knowledge (Being able to handle questions). Due to time constraints, we were only able to produce "knowledge"-based data.

Up until Demo Day, our project heavily depended on RASA NLU, an open-source Python-based library for handling Natural Language processing. However, since then, we have removed Python from the project and rewritten parsing and intent-management code in Racket.

### Deliverable and Demonstration
We have an interactive single page web chat application that has a built in bot. During the demo, one can talk
to the chat robot, and give it some information. The robot is currently unable to "learn". However, it is possible to manually modify the datasets that the bot uses. It can recall information when prompted, as well as have altered dialogue based on user input.

### Evaluation of Results
Multiple clients can chat in the user interface, as well as interact with the bot, therefore we were successful.

## Architecture Diagram
![Architecture](/Architecture_Update.jpg?raw=true "Architecture")

As we developed the application, we modified our base architecture several times. The diagram above reflects how are bot is currently powered.

There are multiple servers running:
1. Web Application (UI)
2. Socket
3. Local REST API

Assuming the 3 servers above are running, everything starts at the "Chat UI" and its Socket, where the user converses with the bot. For example, the user may write: "How are you?". The UI calls a local REST API with the parameters "how are you?". The API uses parsers to map user input with the dataset, using the Levenshtein distance. Once the closest match is found, the appropriate JSON object is returned from the dataset and its `intent` is passed to an intent manager. An intent-response map is stored in memory and used to retrieve a response from the provided intent. The local API finally returns the response to the Chat UI, which uses a socket to display that information in the chat window (under a user named "Bot").

The main UI of this application is the chat box. In what appears to be a standard conversation window between two users, the chat box is the human interface to the machine-learning-based bot. The chatbot appears to be a normal user who intelligently responds to other users. The UI of this application was be created by Scott Mello (@mello244688).

The backend/datasets was primarily worked on by Saurabh Verma (@sv-uml). This includes setting up JSON-based datasets, developing RESTful API for communication with the front-end and writing intent-manager/parser for the bot. Using Sockets allows users to chat with each other, including the bot. This object is a part of the backend. The main components of this area are `web-server` and `db` libraries.

The heart of this project is the Bot and how it uses artificial intelligence to communicate with users.

## Schedule
##### Week 1: Apr 2 - Apr 9
build a basic prototype of the user interface.  
do research on machine learning.  
begin implementing machine learning algorithms.  
##### Week 2: Apr 10 - Apr 16
create and polish the final version of the user interface.  
continue working on implementing machine learning algorithms.  
##### Week 3: Apr 16 - Apr 24
finish implementing machine learning algorithms.  
deploy the webpage to a webhost.  
get people do user testing, and make any necessary changes.  


### First Milestone (Sun Apr 9)
The front-end prototype will be complete.  
Research concerning machine learning ongoing.  
Started to implement machine learning algorithms.  

### Second Milestone (Sun Apr 16)
Front-end is complete.  
Implementation of machine learning algorithms ongoing.  

### Public Presentation (Fri Apr 28)
Implementation of machine learning algorithms are complete.  
Multi client chat is supported with websockets.  
User testing is complete.
Learning capabilities of the bot are very simple. AS a result, advanced conversations cannot be held with the bot yet.

## Group Contributions

#### Scott Mello @mello244688
Built the front end interface, as well as the multi client chat using web sockets.

#### Saurabh Verma @sv-uml
Saurabh worked on building out the backend for the bot. This included setting up the JSON-based dataset, helping the bot "learn" from available data and writing natural language processing algorithms for communication.



