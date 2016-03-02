"use strict";

var growly = require('growly');
var _ = require("lodash");

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

  forward(notification, opts) {
    opts = opts || {};
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

        var text = _.chain([
          notification.options.description,
          notification.options.detail
        ])
        .reject(_.isEmpty)
        .join('\n\n')
        .truncate({
          'length': 128,
          'separator': ' '
        }).value();

        // Send to Growl
        growly.notify(text, {
          title: notification.message,
          label: notification.type
        }, function(err, action) {
          // Handle notfication click
          if (action === 'click' && opts.onClick) {
            var event = new CustomEvent('growl_click', {
              'detail': {
                'notification': notification
              }
            });
            opts.onClick.call(this, event)
          }
        });
        self.count++;
        console.info('🐾 Forwarded to Growl: %o', notification);
        resolve(true);
      });
    });
  }

}
