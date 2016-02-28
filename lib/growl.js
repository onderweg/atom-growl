"use strict";

var growly = require('growly');

// a list of defined notification types
const growlTypes = [{
  label: 'info',
  dispname: 'Info'
}, {
  label: 'success',
  dispname: 'Success',
  enabled: true
}, {
  label: 'warning',
  dispname: 'Warning',
  enabled: true
},{
  label: 'error',
  dispname: 'Error',
  enabled: true
}];

module.exports = class Growl {

  constructor() {
    this.count = 0;
  }

  forward(notification) {
    // url, file path, or Buffer instance for an application icon image.
    var icon =  __dirname + '/../resources/icon.png';

    // Registers a new application with Growl
    var self = this;
    return new Promise( function(resolve, reject) {
      growly.register('atom-growl', icon, growlTypes, function(err) {
        if (err) {
          reject(err);
          return;
        }

        // Send to Growl
        growly.notify(notification.options.detail, {
          title: notification.message,
          label: notification.type
        });
        self.count++;
        console.info('🐾 Forwarded to Growl: %o', notification);
        resolve();
      });
    });
  }

}
