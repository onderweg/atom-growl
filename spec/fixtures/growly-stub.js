"use strict";

module.exports = class GrowlyStub  {

  register(app, icon, types, callback) {
    callback.call(this, null)
  }

  notify(text, options, callback) {
    callback.call(this, null, 'click');
  }

}
