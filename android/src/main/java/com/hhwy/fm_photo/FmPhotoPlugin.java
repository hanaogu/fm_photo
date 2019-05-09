package com.hhwy.fm_photo;

import android.Manifest;
import android.widget.Toast;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.reactivex.Observer;
import io.reactivex.disposables.Disposable;

import com.luck.picture.lib.PictureSelector;
import com.luck.picture.lib.config.PictureConfig;
import com.luck.picture.lib.permissions.RxPermissions;
import com.luck.picture.lib.tools.PictureFileUtils;

import org.json.JSONObject;

import java.lang.reflect.Method;
import java.util.Map;

/** FmPhotoPlugin */
public class FmPhotoPlugin implements MethodCallHandler {
  static  FmPhotoPluginImp _imp;
  /** Plugin registration. */
  public static void registerWith(final Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "fm_photo");
    channel.setMethodCallHandler(new FmPhotoPlugin());
    _imp = new FmPhotoPluginImp(registrar);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    try {
      if( call.method.equals("pickPhoto")){
        _imp.pickPhoto(new JSONObject((Map)call.arguments),result);
      }else if( call.method.equals("cameraPhoto")){
        _imp.cameraPhoto(new JSONObject((Map)call.arguments),result);
      }else if( call.method.equals("getThumbnail")){
        _imp.getThumbnail(new JSONObject((Map)call.arguments),result);
      }else {
        result.notImplemented();
      }
    } catch (Exception e) {
      e.printStackTrace();
      result.notImplemented();
    }
  }
}
