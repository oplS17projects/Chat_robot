window.onload = function () {
    // var sock = new WebSocket("ws://localhost:8081/test", "subprotocol");
    var sock = new WebSocket("ws://localhost:8081/test");

    sock.onopen = function() {
        console.log('open', arguments);
        sock.send("Hi there");
    };
    sock.onmessage = function(e) {
        console.log('message', e.data);
        
        var name = "name";
        
        $('#chatBox').append("<b>" + name + ": </b>" + EscapeHtml(e.data) + "<br>");

    };
    sock.onclose = function() {
        console.log('close', arguments);
    };
    
    $('form').submit(function(e) {
        var msg = $('#usermsg').val();
        $('#usermsg').val("");
        e.preventDefault();
        sock.send(msg);
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