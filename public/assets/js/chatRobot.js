window.onload = function () {
    // var sock = new WebSocket("ws://localhost:8081/test", "subprotocol");
    var sock = new WebSocket("ws://localhost:8081/test");

    sock.onopen = function() {
        console.log('open', arguments);
    };
    sock.onmessage = function(e) {
        $('#chatBox').append("<b>" + GetName(e.data) + ": </b>" + EscapeHtml(GetMessage(e.data)) + "<br>");
    };
    
    sock.onclose = function() {
        console.log('close', arguments);
    };
    
    $('form').submit(function(e) {
        var name = $('#username').val().trim();
        
        if (name) {
            var msg = $('#usermsg').val().trim() + "#name#:" + name;
            $('#usermsg').val("");
            e.preventDefault();
            sock.send(msg);
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

function GetMessage(msg) {
    var name = "#name#:";
    var endIndex = msg.indexOf(name);
    
    return msg.substring(0, endIndex);
}

function GetName(msg) {
    var name = "#name#:";
    var index = msg.indexOf(name);
    var nameIndex = index + name.length;
    
    if (index >= 0) {
        return msg.substring(nameIndex, msg.length);
    }
} 