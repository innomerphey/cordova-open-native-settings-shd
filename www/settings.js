const NativeSettingsShd = function() {};

NativeSettingsShd.open = function(setting, onsuccess, onfail) {
    const settings = (typeof setting === 'string' || setting instanceof String) ? [setting] : setting;
    cordova.exec(onsuccess, onfail, "NativeSettingsShd", "open", settings);
};

module.exports = NativeSettingsShd;
