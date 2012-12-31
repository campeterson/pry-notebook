function Notebook(options) {
    this.bindKeyup();
};

Notebook.openSocket = function(callback) {
    var klass  = ("MozWebSocket" in window) ? MozWebSocket : WebSocket,
        socket = new klass('ws://' + window.location.host);

    socket.onmessage = callback;
};

Notebook.prototype.handleMessage = function(data) {
    var div = $('<div/>').addClass("pry-" + data.type).text(data.value);
    $('.output').append(div);
};

Notebook.prototype.bindKeyup = function () {
    $('input').on('keyup', function (e) {
        if (e.keyCode == 13) {
            $.post('/', $(this).val());
            $(this).val('');
        }
    });
};
