Zotero.Hiberlink = {
    DB: null,
    archiveUrl: null,
    intervalID: null,
    count: null,
    insertID: null,
    item: null,

    init: function () {
        // Connect to (and create, if necessary) hiberlink.sqlite in the Zotero directory
        this.DB = new Zotero.DBConnection('hiberlink');

        if (!this.DB.tableExists('changes')) {
            this.DB.query("CREATE TABLE changes (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, itemid INTEGER, " +
                "version INTEGER NOT NULL, title TEXT, url TEXT, archiveurl TEXT, timestamp DATETIME DEFAULT NULL)");
        }

        // Register the callback in Zotero as an item observer
        var notifierID = Zotero.Notifier.registerObserver(this.notifierCallback, ['item']);

        // Unregister callback when the window closes (important to avoid a memory leak)
        window.addEventListener('unload', function (e) {
            Zotero.Notifier.unregisterObserver(notifierID);
        }, false);
    },

    getReport: function () {
        // Display additional window to show report of archived links
        var col = ZoteroPane_Local.getSelectedItems();
        var params = "zotero://hiberlink/content/report.html?";
        for (var i = 0; i < col.length; i++) {
            params += "item=" + col[i].id + "&";
        }
        Zotero.debug("Url: " + params);
        ZoteroPane_Local.loadURI(params.substring(0, params.length - 1));
    },

    // Callback implementing the notify() method to pass to the Notifier
    notifierCallback: {
        notify: function (event, type, ids, extraData) {
            if (event == 'add' || event == 'modify') {
                var ps = Components.classes["@mozilla.org/embedcomp/prompt-service;1"]
                    .getService(Components.interfaces.nsIPromptService);
                // Loop through array of items and grab titles
                Zotero.debug("Ids size: " + ids.length);
                if (ids.length > 1) {
                    // TODO: Handle deletion of references
                    for (var id in ids) {
                        Zotero.Hiberlink.item = Zotero.Items.get(id);
                        Zotero.debug("ID: " + Zotero.Hiberlink.item);
                        // For deleted items, get title from passed data
                        if (typeof Zotero.Hiberlink.item === 'object') {
                            if (Zotero.Hiberlink.item.getField('url') != '') {
//                                alert("URL: " + Zotero.Hiberlink.item.getField('url'));
                            }
                        }
                    }
                } else {
                    Zotero.Hiberlink.item = Zotero.Items.get(ids)[0];
                    if (typeof Zotero.Hiberlink.item === 'object') {
                        var url = Zotero.Hiberlink.item.getField('url');
                        var itemId = Zotero.Hiberlink.item.getField('id');
                        var title = Zotero.Hiberlink.item.getField('title');
                        var oldRecord = Zotero.Hiberlink.DB.query("SELECT url, version FROM changes WHERE itemid='" +
                            itemId + "' ORDER BY version DESC LIMIT 1");
                        var oldUrl = null;
                        var oldVersion = 0;
                        if (oldRecord) {
                            oldUrl = oldRecord[0]['url'];
                            oldVersion = oldRecord[0]['version'];
                        }
                        if (url != '' && url != oldUrl) {
                            var xhr = new XMLHttpRequest();
                            var object = this;
                            xhr.open('POST', 'http://archive.today/submit/', true);
                            xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
                            xhr.onload = function () {
                                if (xhr.getResponseHeader('refresh') != null) {
                                    Zotero.Hiberlink.archiveUrl = xhr.getResponseHeader('refresh').split('url=')[1];
                                    Zotero.debug("Querying archive url: " + Zotero.Hiberlink.archiveUrl);
                                    Zotero.Hiberlink.insertID = Zotero.Hiberlink.DB.query("INSERT INTO changes (itemid, version, title, url, archiveurl) VALUES ('" + itemId + "', '" + ++oldVersion + "', '" + title + "', '" + url + "', '" + Zotero.Hiberlink.archiveUrl + "')");
                                    Zotero.Hiberlink.count = 0;
                                    Zotero.Hiberlink.intervalID = setInterval(Zotero.Hiberlink.checkArchiveUrl, 5000);
                                    Zotero.Hiberlink.item.setField('archive', Zotero.Hiberlink.archiveUrl);
                                    Zotero.Hiberlink.item.save();
                                } else {
                                    Zotero.debug("Archival service did not accept the URL '" + url + "'");
                                }
                            };
                            xhr.onerror = function () {
                                ps.alert(null, "", Zotero.getString('hiberlink.fail', [url]));
                                var insertId = Zotero.Hiberlink.DB.query("INSERT INTO changes (itemid, title, url) VALUES ('" + itemId + "', '" + title + "', '" + url + "')");
                            };
                            xhr.send('url=' + url);
                        }
                    }
                }
            }
        }
    },
    refreshArchive: function () {
        // Create copy of reference and rearchive
        ZoteroPane_Local.duplicateSelectedItem();
        var item = ZoteroPane_Local.getSelectedItems()[0];
        item.setField('title', item.getField('title') + ' (' + new Date() + ')');
    },
    checkArchiveUrl: function () {
        // Query archival service to check archive has been made
        var xhr2 = new XMLHttpRequest();
        xhr2.open('GET', Zotero.Hiberlink.archiveUrl, true);
        xhr2.onload = function () {
            var datetime = xhr2.getResponseHeader('Memento-Datetime');
            Zotero.debug("Archive header: " + datetime);
            Zotero.debug("Count: " + Zotero.Hiberlink.count);
            if (Zotero.Hiberlink.count++ > 5 || datetime != null) {
                Zotero.debug("Clearing interval with ID: " + Zotero.Hiberlink.intervalID);
                clearInterval(Zotero.Hiberlink.intervalID);
                if (datetime != null) {
                    var utcDate = Zotero.Date.dateToSQL(new Date(datetime), true);
                    var date = Zotero.Date.dateToSQL(new Date(datetime));
                    Zotero.Hiberlink.item.setField('accessDate', utcDate);
                    Zotero.Hiberlink.item.save();
                    Zotero.Hiberlink.DB.query("UPDATE changes SET timestamp='" + date + "' WHERE id='" + Zotero.Hiberlink.insertID + "'");
                }
            }
            if (Zotero.Hiberlink.count > 5) {
                Zotero.debug("Archiving of URL timed out");
            }
        };
        xhr2.send();
    }
};

// Initialize the utility
window.addEventListener('load', function (e) {
    Zotero.Hiberlink.init();
}, false);