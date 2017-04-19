window.onload = function () {
    // var sock = new WebSocket("ws://localhost:8081/test", "subprotocol");
    var sock = new WebSocket("ws://localhost:8081/test");

    sock.onopen = function() {
        console.log('open', arguments);
    };
    sock.onmessage = function(e) {
        var msgObj = JSON.parse(e.data);
        $('#chatBox').append("<b>" + msgObj.username + ": </b>" + EscapeHtml(msgObj.msg) + "<br>");
    };
    
    sock.onclose = function() {
        console.log('close', arguments);
    };
    
    $('form').submit(function(e) {
        
        var name = $('#username').val().trim();
        var message = $('#usermsg').val().trim();
        
        if (name) {
            $('#usermsg').val("");
            e.preventDefault();
            sock.send(JSON.stringify({ msg: message, username: name }));
        }
        else {
            e.preventDefault();
        }
    }); 
};

function EscapeHtml(s) {
    return s.replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/'/g, '&apos;')
        .replace(/"/g, '&quot;')
        .replace(/\//g, '&sol;');
}