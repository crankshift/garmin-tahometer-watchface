import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class TachometerWatchFaceApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() as Array<WatchUi.Views or WatchUi.InputDelegates>? {
        return [new TachometerWatchFaceView()] as Array<WatchUi.Views or WatchUi.InputDelegates>;
    }

    // The Minute Style setting redraws the face without restarting it.
    function onSettingsChanged() as Void {
        WatchUi.requestUpdate();
    }
}
