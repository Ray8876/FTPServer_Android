package top.ray8876.one_click_ftp.activities;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.graphics.Point;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.Display;
import android.view.KeyCharacterMap;
import android.view.KeyEvent;
import android.view.ViewConfiguration;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.core.content.PermissionChecker;

import org.apache.log4j.BasicConfigurator;
import org.json.JSONArray;
import org.json.JSONObject;

import java.util.List;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import top.ray8876.one_click_ftp.Constants;
import top.ray8876.one_click_ftp.data.AccountItem;
import top.ray8876.one_click_ftp.services.FtpService;
import top.ray8876.one_click_ftp.utils.MySQLiteOpenHelper;
import top.ray8876.one_click_ftp.utils.Storage;
import top.ray8876.one_click_ftp.utils.ValueUtil;

import static top.ray8876.one_click_ftp.activities.BaseActivity.activityStack;

public class FlutterMainActivity extends FlutterActivity {

    private static final String eventChannel = "top.ray8876.one_click_ftp/EventInfo";
    private EventChannel.EventSink eventSink;
    private SharedPreferences settings = null;
    private SharedPreferences.Editor editor = null;

    private int ftpPort1 = 0;
    private String charset1 = "";
    private int ftpPort2 = 0;
    private String charset2 = "";
    private String anonymousPath = "";
    private Boolean anonymousWritable = false;
    private String path = Storage.getMainStoragePath();

    private boolean ifWakeLock = false;
    private List<AccountItem> list = null;

    /**
     * 开启MethodChannel监听通道
     * 参考官网https://flutter.dev/docs/development/platform-integration/platform-channels
     * edit by Ray8876 2020.02.02
     */
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {

        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), eventChannel)
                .setStreamHandler(new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object o, EventChannel.EventSink _eventSink) {
                        eventSink = _eventSink;
                        // Log.i("EventChannel","eventSink onListen done!");
                    }

                    @Override
                    public void onCancel(Object o) {

                    }
                });

        GeneratedPluginRegistrant.registerWith(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "top.ray8876.one_click_ftp/StartFTP")
                .setMethodCallHandler((call, result) -> {
                    if (FtpService.listener == null) {
                        startFTPServiceStatusChangedListener();
                    }
                    if (call.method.equals("StartFTP1")) {
                        if (!FtpService.isFTPServiceRunning()) {
                            if (Build.VERSION.SDK_INT >= 23 && PermissionChecker.checkSelfPermission(
                                    FlutterMainActivity.this,
                                    Manifest.permission.WRITE_EXTERNAL_STORAGE) != PermissionChecker.PERMISSION_GRANTED) {
                                // showSnackBarOfRequestingWritingPermission();
                                requestPermissions(new String[] { Manifest.permission.WRITE_EXTERNAL_STORAGE }, 0);
                                return;
                            }
                            editor = settings.edit();
                            editor.putInt(Constants.PreferenceConsts.PORT_NUMBER, ftpPort1);
                            editor.putString(Constants.PreferenceConsts.CHARSET_TYPE, charset1);
                            editor.putBoolean(Constants.PreferenceConsts.ANONYMOUS_MODE, true);
                            editor.apply();
                            FtpService.startService(FlutterMainActivity.this);
                        } else {
                            FtpService.stopService();
                        }
                        result.success("done");
                    } else if (call.method.equals("StartFTP2")) {
                        if (!FtpService.isFTPServiceRunning()) {
                            if (Build.VERSION.SDK_INT >= 23 && PermissionChecker.checkSelfPermission(
                                    FlutterMainActivity.this,
                                    Manifest.permission.WRITE_EXTERNAL_STORAGE) != PermissionChecker.PERMISSION_GRANTED) {
                                // showSnackBarOfRequestingWritingPermission();
                                requestPermissions(new String[] { Manifest.permission.WRITE_EXTERNAL_STORAGE }, 0);
                                return;
                            }
                            if (FtpService.getUserAccountList(FlutterMainActivity.this).size() == 0) {
                                result.success("0");
                                return;
                            }
                            editor = settings.edit();
                            editor.putInt(Constants.PreferenceConsts.PORT_NUMBER, ftpPort2);
                            editor.putString(Constants.PreferenceConsts.CHARSET_TYPE, charset2);
                            editor.putBoolean(Constants.PreferenceConsts.ANONYMOUS_MODE, false);
                            editor.apply();
                            FtpService.startService(FlutterMainActivity.this);
                        } else {
                            FtpService.stopService();
                        }
                        result.success("done");
                    }
                });

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "top.ray8876.one_click_ftp/SetData")
                .setMethodCallHandler((call, result) -> {
                    try {
                        if (call.method.equals("GetInitialValue")) {
                            JSONObject _obj = new JSONObject();
                            _obj.put("port", ftpPort1);
                            _obj.put("charset", charset1);
                            _obj.put("ifWakeLock", ifWakeLock);
                            _obj.put("anonymousPath", anonymousPath);
                            if (anonymousWritable)
                                _obj.put("anonymousWritable", "允许");
                            else
                                _obj.put("anonymousWritable", "拒绝");
                            result.success(_obj.toString());
                        } else {
                            JSONObject _obj = new JSONObject(call.method);
                            Log.i("SetInitialValue", _obj.toString());
                            ftpPort1 = _obj.getInt("port");
                            charset1 = _obj.getString("charset");
                            anonymousPath = _obj.getString("anonymousPath");
                            anonymousWritable = _obj.getString("anonymousWritable").equals("允许");
                            editor = settings.edit();
                            editor.putInt(Constants.PreferenceConsts.PORT_NUMBER1, ftpPort1);
                            editor.putString(Constants.PreferenceConsts.CHARSET_TYPE1, charset1);
                            editor.putString(Constants.PreferenceConsts.ANONYMOUS_MODE_PATH, anonymousPath);
                            editor.putBoolean(Constants.PreferenceConsts.ANONYMOUS_MODE_WRITABLE, anonymousWritable);
                            editor.apply();
                            result.success("done!]");
                        }
                    } catch (Exception e) {
                        result.error("-1", "error", e.toString());
                    }

                });

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "top.ray8876.one_click_ftp/SetData2")
                .setMethodCallHandler((call, result) -> {
                    try {
                        if (call.method.equals("GetInitialValue")) {

                            JSONObject _obj = new JSONObject();
                            _obj.put("port", ftpPort2);
                            _obj.put("charset", charset2);
                            _obj.put("path", path);
                            JSONArray userList = new JSONArray();

                            for (AccountItem account : list) {
                                userList.put(account.toString());
                            }

                            _obj.put("userList", userList);
                            result.success(_obj.toString());
                        } else {
                            JSONObject _obj = new JSONObject(call.method);
                            Log.i("SetInitialValue", _obj.toString());
                            ftpPort2 = _obj.getInt("port");
                            charset2 = _obj.getString("charset");
                            editor = settings.edit();
                            editor.putInt(Constants.PreferenceConsts.PORT_NUMBER2, ftpPort2);
                            editor.putString(Constants.PreferenceConsts.CHARSET_TYPE2, charset2);

                            editor.apply();
                            result.success("done!]");
                        }
                    } catch (Exception e) {
                        result.error("-1", "error", e.toString());
                    }
                });

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "top.ray8876.one_click_ftp/SetUserList")
                .setMethodCallHandler((call, result) -> {
                    try {

                        JSONObject _obj = new JSONObject(call.method);
                        Log.i("SetUserList", _obj.toString());
                        String _action = _obj.getString("action");

                        switch (_action) {
                        case "add": {
                            AccountItem _item = new AccountItem();
                            _item.account = _obj.getString("account");
                            _item.password = _obj.getString("password");
                            // _item.path = _obj.getString("path");
                            _item.path = _obj.getString("path");
                            _item.writable = _obj.getBoolean("writable");
                            MySQLiteOpenHelper.saveOrUpdateAccountItem2DB(this, _item, null);
                            list = FtpService.getUserAccountList(this);
                            result.success("done!]");
                            break;
                        }
                        case "edit": {
                            AccountItem _item = new AccountItem();
                            long _id = _obj.getLong("id");
                            _item.account = _obj.getString("account");
                            _item.password = _obj.getString("password");
                            _item.path = _obj.getString("path");
                            _item.writable = _obj.getBoolean("writable");
                            MySQLiteOpenHelper.saveOrUpdateAccountItem2DB(this, _item, _id);
                            list = FtpService.getUserAccountList(this);
                            result.success("done!]");
                            break;
                        }
                        case "delete": {
                            long _id = _obj.getLong("id");
                            MySQLiteOpenHelper.deleteRow(this, _id);
                            list = FtpService.getUserAccountList(this);
                            result.success("done!]");
                            break;
                        }
                        case "get": {
                            JSONArray userList = new JSONArray();
                            for (AccountItem account : list) {
                                userList.put(account.toString());
                            }
                            result.success(userList.toString());
                            break;
                        }
                        }

                    } catch (Exception e) {
                        result.error("-1", "error", e.toString());
                    }
                });
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {

        setStatus(this);
        super.onCreate(savedInstanceState);
        // setContentView(R.layout.activity_flutter);
        BasicConfigurator.configure();
        // 初始化值
        initValue();
        // 初始化FlutterEngine，利用缓存加速开启flutterActivity
        // initFlutterEngine();
        // 初始化界面，设置按钮监听，后续换成动画页面自动进入flutter页面
        // initView();
        FlutterEngine flutterEngine = new FlutterEngine(this);

        // Start executing Dart code to pre-warm the FlutterEngine.
        flutterEngine.getDartExecutor().executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault());

        // Cache the FlutterEngine to be used by FlutterActivity.
        FlutterEngineCache.getInstance().put("my_engine", flutterEngine);

        Context currentActivity = FlutterMainActivity.this;
        startActivity(
                io.flutter.embedding.android.FlutterActivity.withCachedEngine("my_engine").build(currentActivity));

        // 设置监听
        configureFlutterEngine(flutterEngine);

    }


    private void initValue() {
        settings = getSharedPreferences(Constants.PreferenceConsts.FILE_NAME, Context.MODE_PRIVATE);

        ftpPort1 = settings.getInt(Constants.PreferenceConsts.PORT_NUMBER1,
                Constants.PreferenceConsts.PORT_NUMBER1_DEFAULT);
        charset1 = settings.getString(Constants.PreferenceConsts.CHARSET_TYPE1,
                Constants.PreferenceConsts.CHARSET_TYPE1_DEFAULT);
        ftpPort2 = settings.getInt(Constants.PreferenceConsts.PORT_NUMBER2,
                Constants.PreferenceConsts.PORT_NUMBER2_DEFAULT);
        charset2 = settings.getString(Constants.PreferenceConsts.CHARSET_TYPE2,
                Constants.PreferenceConsts.CHARSET_TYPE2_DEFAULT);

        ifWakeLock =
                settings.getBoolean(Constants.PreferenceConsts.WAKE_LOCK, Constants.PreferenceConsts.WAKE_LOCK_DEFAULT);
        anonymousPath = settings.getString(Constants.PreferenceConsts.ANONYMOUS_MODE_PATH,
                Constants.PreferenceConsts.ANONYMOUS_MODE_PATH_DEFAULT);
        anonymousWritable = settings.getBoolean(Constants.PreferenceConsts.ANONYMOUS_MODE_WRITABLE,
                Constants.PreferenceConsts.ANONYMOUS_MODE_WRITABLE_DEFAULT);
        list = FtpService.getUserAccountList(this);

        if (Build.VERSION.SDK_INT >= 23 && PermissionChecker.checkSelfPermission(FlutterMainActivity.this,
                Manifest.permission.WRITE_EXTERNAL_STORAGE) != PermissionChecker.PERMISSION_GRANTED) {
            // showSnackBarOfRequestingWritingPermission();
            requestPermissions(new String[] { Manifest.permission.WRITE_EXTERNAL_STORAGE }, 0);
            return;
        }
        startFTPServiceStatusChangedListener();

    }

    // private void showSnackBarOfRequestingWritingPermission(){
    // Snackbar
    // snackbar=Snackbar.make(findViewById(android.R.id.content),getResources().getString(R.string.permission_write_external),Snackbar.LENGTH_SHORT);
    // snackbar.setAction(getResources().getString(R.string.snackbar_action_goto), new View.OnClickListener() {
    // @Override
    // public void onClick(View v) {
    // Intent appdetail = new Intent();
    // appdetail.setAction(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
    // appdetail.setData(Uri.fromParts("package", getApplication().getPackageName(), null));
    // startActivity(appdetail);
    // }
    // });
    // snackbar.show();
    // }

    @Override
    protected void onResume() {
        super.onResume();
        // refreshIgnoreBatteryStatus();
    }

    // private void refreshIgnoreBatteryStatus(){
    // try{
    // if(Build.VERSION.SDK_INT>=23){
    // ViewGroup ignore_battery=findViewById(R.id.battery_area);
    // PowerManager powerManager=(PowerManager)getSystemService(Context.POWER_SERVICE);
    // if(!powerManager.isIgnoringBatteryOptimizations(getPackageName())){
    // ignore_battery.setVisibility(View.VISIBLE);
    // ignore_battery.setOnClickListener(new View.OnClickListener() {
    // @Override
    // public void onClick(View v) {
    // Intent intent = new Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS);
    // intent.seteData(Uri.parse("package:"+getPackageName()));
    // startActivity(intent);
    // }
    // });
    // }else ignore_battery.setVisibility(View.GONE);
    // }
    // }catch (Exception e){e.printStackTrace();}
    // }

    @Override
    public void finish() {
        super.finish();
        try {
            while (activityStack != null && activityStack.size() > 0)
                activityStack.getLast().finish();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        FtpService.setOnFTPServiceStatusChangedListener(null);
    }

    private void startFTPServiceStatusChangedListener() {
        FtpService.setOnFTPServiceStatusChangedListener(new FtpService.OnFTPServiceStatusChangedListener() {
            @Override
            public void onFTPServiceStarted() {
                // switchCompat.setEnabled(true);
                // switchCompat.setChecked(true);
                JSONObject js = new JSONObject();
                try {
                    js.put("status", "run");
                    js.put("info", ValueUtil.getFTPServiceFullAddress(FlutterMainActivity.this));
                } catch (Exception e) {
                    Log.e("JSONObject_js", e.toString());
                }
                eventSink.success(js.toString());
            }

            @Override
            public void onFTPServiceStartError(Exception e) {
                // switchCompat.setEnabled(true);
                // switchCompat.setChecked(false);
                JSONObject js = new JSONObject();
                try {
                    js.put("status", "error");
                    js.put("info", e.toString());
                } catch (Exception _e) {
                    Log.e("JSONObject_js", _e.toString());
                }
                eventSink.success(js.toString());

                Toast.makeText(FlutterMainActivity.this, e.toString(), Toast.LENGTH_SHORT).show();
            }

            @Override
            public void onFTPServiceDestroyed() {
                // switchCompat.setChecked(false);
                // switchCompat.setEnabled(true);
                JSONObject js = new JSONObject();
                try {
                    js.put("status", "stop");
                    js.put("info", "");
                } catch (Exception _e) {
                    Log.e("JSONObject_js", _e.toString());
                }
                eventSink.success(js.toString());
            }
        });
    }

    public void setStatus(Activity activity) {
        if (!isNavigationBarShow(activity)) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);// 窗口透明的状态栏
                activity.requestWindowFeature(Window.FEATURE_NO_TITLE);// 隐藏标题栏
                activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);// 窗口透明的导航栏
            }
        } else {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                activity.getWindow().setStatusBarColor(Color.TRANSPARENT);
            }
        }
    }

    // 是否是虚拟按键的设备
    private boolean isNavigationBarShow(Activity activity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            Display display = activity.getWindowManager().getDefaultDisplay();
            Point size = new Point();
            Point realSize = new Point();
            display.getSize(size);
            display.getRealSize(realSize);
            return realSize.y != size.y;
        } else {
            boolean menu = ViewConfiguration.get(activity).hasPermanentMenuKey();
            boolean back = KeyCharacterMap.deviceHasKey(KeyEvent.KEYCODE_BACK);
            return !menu && !back;
        }
    }

}
