describe("Pry Notebook", function() {
    beforeEach(function() {
        this.output   = { append: jasmine.createSpy("append") };
        this.input    = { on: jasmine.createSpy("on") };
        this.notebook = new Notebook({
                            output: this.output,
                            input: this.input
                        });
    });

    var describeMessageType = function(type, options, cb) {
        describe("handling " + type + " responses", function() {
            beforeEach(function() {
                this.notebook.handleMessage(
                    _.extend({}, options, { type: type })
                );

                var call = this.output.append.mostRecentCall;
                this.el  = call && call.args && call.args[0];
            });

            it("appends them to the output div", function() {
                expect(this.output.append).toHaveBeenCalled();
            });

            cb.call(this);
        });
    };

    describeMessageType("result", { value: "100" }, function() {
        it("uses the class 'pry-result'", function() {
            expect(this.el.hasClass("pry-result")).toBe(true);
        });

        it("prepends =>", function() {
            expect(this.el.text()).toBe("=> 100");
        });
    });

    describeMessageType("output", { value: "hey\nb a b y" }, function() {
        it("uses the class 'pry-output'", function() {
            expect(this.el.hasClass("pry-output")).toBe(true);
        });

        it("preserves line breaks and whitespace", function() {
            expect(this.el.html()).toBe("hey<br>b&nbsp;a&nbsp;b&nbsp;y");
        });

        it("does not prepend =>", function() {
            expect(this.el.html()).not.toMatch(/^=> /);
        });
    });

    describeMessageType("error", { value: "Some Message" }, function() {
        it("uses the class 'pry-error'", function() {
            expect(this.el.hasClass("pry-error")).toBe(true);
        });
    });
});
