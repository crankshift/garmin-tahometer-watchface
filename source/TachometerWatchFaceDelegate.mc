import Toybox.Lang;
import Toybox.WatchUi;

// Relays onPowerBudgetExceeded to the view, since only a WatchFaceDelegate receives it.
class TachometerWatchFaceDelegate extends WatchUi.WatchFaceDelegate {
    private var _view as TachometerWatchFaceView;

    function initialize(view as TachometerWatchFaceView) {
        WatchFaceDelegate.initialize();
        _view = view;
    }

    function onPowerBudgetExceeded(powerInfo as WatchFacePowerInfo) as Void {
        _view.onPowerBudgetExceeded();
    }
}
