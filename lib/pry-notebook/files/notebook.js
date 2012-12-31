function Notebook(options) {
    this.output = options.output;
    this.input  = options.input;
    this.bindKeyup();
};

Notebook.openSocket = function(callback) {
    var klass  = ("MozWebSocket" in window) ? MozWebSocket : WebSocket,
        socket = new klass('ws://' + window.location.host);

    socket.onmessage = callback;
};

Notebook.prototype.handleMessage = function(data) {
    var html = $('<div/>').text(data.value).html(),
        div  = $('<div/>').addClass("pry-" + data.type);

    html = html.replace(/\n/g, "<br>");

    if (data.type == "result") {
        html = "=> " + html;
    }

    this.output.append(div.html(html));
};

Notebook.prototype.sendLine = function(line) {
    $.post('/', line);
};

Notebook.prototype.bindKeyup = function () {
    var self = this;

    this.input.on('keyup', function (e) {
        if (e.keyCode == 13) {
            self.sendLine($(this).val());
            $(this).val('');
        }
    });
};
