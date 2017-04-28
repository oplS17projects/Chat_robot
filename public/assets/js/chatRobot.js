window.onload = function () {

    var sock = new WebSocket("ws://localhost:3000/chat");

    sock.onopen = function() {
        console.log('open', arguments);
    };
    
    sock.onmessage = function(e) {
        var msgObj = JSON.parse(e.data);
        
        if (typeof msgObj == "object") {
            $('#chatBox').append("<b>" + EscapeHtml(msgObj.username) + ": </b>" + EscapeHtml(msgObj.msg) + "<br>");
            AutoScroll();
        }
        else {
            console.log("count = " + e.data);
            $('#clients').empty();
            $('#clients').append('<b>Active Clients: </b>' + e.data);
        }
        
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
    
    window.onbeforeunload = function() {
        sock.send("close");
    };
};

function AutoScroll() {
    var chat = $('#chatBox');
    chat.scrollTop(chat[0].scrollHeight);
}

function EscapeHtml(s) {
    return s.replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/'/g, '&apos;')
        .replace(/"/g, '&quot;')
        .replace(/\//g, '&sol;');
}