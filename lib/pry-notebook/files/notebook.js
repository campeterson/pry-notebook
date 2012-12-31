function Notebook(options) {
    this.output  = options.output;
    this.input   = options.input;
    this.partial = options.partial;
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

    html = html.replace(/\n$/, "");
    html = html.replace(/\n/g, "<br>");
    html = html.replace(/  /g,  "&nbsp; ");

    switch (data.type) {
        case "continuation":
            this.handleContinuation(html);
            break;
        case "result":
            this.clearContinuationArea();
            html = "=> " + html;
            // fall through
        default:
            this.output.append(div.html(html));
    }
};

Notebook.prototype.clearContinuationArea = function() {
    this.partial.html("");
};

Notebook.prototype.handleContinuation = function(html) {
    this.partial.html(html);
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
