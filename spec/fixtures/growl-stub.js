"use strict";

var Growl = require('../../lib/growl.js');

module.exports = class GrowlStub extends Growl {

  forward(notification) {
    var self = this;
    return new Promise( function(resolve, reject) {
      self.count++;
      resolve(true)
    });
  }

}
