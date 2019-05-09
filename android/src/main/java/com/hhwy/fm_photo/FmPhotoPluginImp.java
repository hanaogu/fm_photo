package com.hhwy.fm_photo;

import android.Manifest;
import android.content.Intent;
import android.graphics.Bitmap;
import android.media.MediaMetadataRetriever;
import android.os.Environment;
import android.util.Log;
import android.widget.Toast;

import com.luck.picture.lib.PictureSelector;
import com.luck.picture.lib.config.PictureConfig;
import com.luck.picture.lib.entity.LocalMedia;
import com.luck.picture.lib.permissions.RxPermissions;
import com.luck.picture.lib.tools.PictureFileUtils;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.reactivex.Observer;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Function;

import static io.reactivex.Completable.complete;

public class FmPhotoPluginImp {
    private final PluginRegistry.Registrar _registrar;
    MethodChannel.Result _result;
    private boolean isPhoto;
    FmPhotoPluginImp(final PluginRegistry.Registrar registrar){
        _registrar = registrar;
        _registrar.addActivityResultListener(new PluginRegistry.ActivityResultListener() {
            @Override
            public boolean onActivityResult(int i, int i1, Intent intent) {
                if ( i == PictureConfig.CHOOSE_REQUEST ){
                    // 图片选择结果回调
                    List<LocalMedia> selectList = PictureSelector.obtainMultipleResult(intent);
                    if(!isPhoto){
                        LocalMedia media = selectList.get(0);
                        HashMap<String,Object> m = new HashMap<>();
                        m.put("path",media.getPath());//为原图path
                        m.put("compressPath",media.getCompressPath());//为压缩后path，需判断media.isCompressed();是否为true
                        m.put("cutPath",media.getCutPath());//为裁剪后path，需判断media.isCut();是否为true
                        m.put("duration",media.getDuration());
                        m.put("pictureType",media.getPictureType());
                        m.put("width",media.getWidth());
                        m.put("height",media.getHeight());
                        m.put("position",media.getPosition());
                        _result.success(m);
                        _result = null;
                        return  true;
                    }
                    // 例如 LocalMedia 里面返回三种path
                    // 1.media.getPath(); 为原图path
                    // 2.media.getCutPath();为裁剪后path，需判断media.isCut();是否为true
                    // 3.media.getCompressPath();为压缩后path，需判断media.isCompressed();是否为true
                    // 如果裁剪并压缩了，已取压缩路径为准，因为是先裁剪后压缩的
                    ArrayList<HashMap<String,Object>> paths= new ArrayList<>();
                    for (LocalMedia media : selectList) {
                        HashMap<String,Object> m = new HashMap<>();
                        m.put("path",media.getPath());//为原图path
                        m.put("compressPath",media.getCompressPath());//为压缩后path，需判断media.isCompressed();是否为true
                        m.put("cutPath",media.getCutPath());//为裁剪后path，需判断media.isCut();是否为true
                        m.put("duration",media.getDuration());
                        m.put("pictureType",media.getPictureType());
                        m.put("width",media.getWidth());
                        m.put("height",media.getHeight());
                        m.put("position",media.getPosition());
                        paths.add(m);
                    }

                    _result.success(paths);
                    _result = null;
                    return  true;
                }
                _result.success(false);
                return false;
            }
        });
    }

    public void pickPhoto(final JSONObject obj, final MethodChannel.Result result){
        isPhoto = true;
        RxPermissions permissions = new RxPermissions(_registrar.activity());
        permissions.request(Manifest.permission.WRITE_EXTERNAL_STORAGE).subscribe(new Observer<Boolean>() {
            @Override
            public void onSubscribe(Disposable d) {
            }

            @Override
            public void onNext(Boolean aBoolean) {
                if (aBoolean) {
                    PictureFileUtils.deleteCacheDirFile(_registrar.activity());
                    _result = result;
                    pickPhoto(obj);
                } else {
                    result.success(false);
                    Toast.makeText(_registrar.activity(),
                            "error ", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onError(Throwable e) {
                result.success(false);
            }

            @Override
            public void onComplete() {
            }
        });
    }

    public void cameraPhoto(final JSONObject obj, final MethodChannel.Result result){
        isPhoto = false;
        RxPermissions permissions = new RxPermissions(_registrar.activity());
        permissions.request(Manifest.permission.WRITE_EXTERNAL_STORAGE).subscribe(new Observer<Boolean>() {
            @Override
            public void onSubscribe(Disposable d) {
            }

            @Override
            public void onNext(Boolean aBoolean) {
                if (aBoolean) {
                    PictureFileUtils.deleteCacheDirFile(_registrar.activity());
                    _result = result;
                    cameraPhoto(obj);
                } else {
                    result.success(false);
                    Toast.makeText(_registrar.activity(),
                            "error ", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onError(Throwable e) {
                result.success(false);
            }

            @Override
            public void onComplete() {
            }
        });
    }

    private void pickPhoto(final JSONObject obj){
        try {
            PictureSelector.create(_registrar.activity())
                    .openGallery(obj.getInt("openGallery"))// 全部.PictureMimeType.ofAll()、图片.ofImage()、视频.ofVideo()、音频.ofAudio()
//                        .theme(themeId)// 主题样式设置 具体参考 values/styles   用法：R.style.picture.white.style
                    .maxSelectNum(obj.getInt("max"))// 最大图片选择数量
                    .minSelectNum(1)// 最小选择数量
                    .imageSpanCount(obj.getInt("spanCount"))// 每行显示个数
                    .selectionMode(obj.getInt("max")>1? PictureConfig.MULTIPLE :PictureConfig.SINGLE)// 多选 or 单选
                    .previewImage(true)// 是否可预览图片
                    .previewVideo(true)// 是否可预览视频
                    .enablePreviewAudio(true) // 是否可播放音频
                    .isCamera(obj.getBoolean("enableCamera"))// 是否显示拍照按钮
//                            .isZoomAnim(obj.getBoolean("enableZoomAnim"))// 图片列表点击 缩放效果 默认true
                    //.imageFormat(PictureMimeType.PNG)// 拍照保存图片格式后缀,默认jpeg
                    //.setOutputCameraPath("/CustomPath")// 自定义拍照保存路径
                    .enableCrop(obj.getBoolean("enableCrop"))// 是否裁剪
                    .compress(obj.getBoolean("enableCompress"))// 是否压缩
//                            .synOrAsy(obj.getBoolean("enableSync"))//同步true或异步false 压缩 默认同步
                    .compressSavePath(obj.getString("compressSavePath"))//压缩图片保存地址
                    //.sizeMultiplier(0.5f)// glide 加载图片大小 0~1之间 如设置 .glideOverride()无效
                    .glideOverride(160, 160)// glide 加载宽高，越小图片列表越流畅，但会影响列表图片浏览的清晰度
//                        .withAspectRatio(aspect_ratio_x, aspect_ratio_y)// 裁剪比例 如16:9 3:2 3:4 1:1 可自定义
//                            .hideBottomControls(!obj.getBoolean("enableBottomControls"))// 是否显示uCrop工具栏，默认不显示
                    .isGif(obj.getBoolean("enableGif"))// 是否显示gif图片
                    .freeStyleCropEnabled(true)// 裁剪框是否可拖拽
                    .circleDimmedLayer(obj.getBoolean("enableCircleDimmedLayer"))// 是否圆形裁剪
//                        .showCropFrame(cb_showCropFrame.isChecked())// 是否显示裁剪矩形边框 圆形裁剪时建议设为false
//                        .showCropGrid(cb_showCropGrid.isChecked())// 是否显示裁剪矩形网格 圆形裁剪时建议设为false
//                        .openClickSound(cb_voice.isChecked())// 是否开启点击声音
//                        .selectionMedia(selectList)// 是否传入已选图片
                    //.isDragFrame(false)// 是否可拖动裁剪框(固定)
//                        .videoMaxSecond(15)
//                        .videoMinSecond(10)
//                    .previewEggs(true)// 预览图片时 是否增强左右滑动图片体验(图片滑动一半即可看到上一张是否选中)
                    //.cropCompressQuality(90)// 裁剪压缩质量 默认100
                    .minimumCompressSize(100)// 小于100kb的图片不压缩
                    //.cropWH()// 裁剪宽高比，设置如果大于图片本身宽高则无效
                    //.rotateEnabled(true) // 裁剪是否可旋转图片
                    .scaleEnabled(true)// 裁剪是否可放大缩小图片
                    //.videoQuality()// 视频录制质量 0 or 1
                    //.videoSecond()//显示多少秒以内的视频or音频也可适用
                    .recordVideoSecond(obj.getInt("recordVideoSecond"))//录制视频秒数 默认60s
                    .forResult(PictureConfig.CHOOSE_REQUEST);//结果回调onActivityResult code
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
    private void cameraPhoto(final JSONObject obj){
        try {
            PictureSelector.create(_registrar.activity())
                    .openCamera(obj.getInt("openCamera"))// 全部.PictureMimeType.ofAll()、图片.ofImage()、视频.ofVideo()、音频.ofAudio()
//                        .theme(themeId)// 主题样式设置 具体参考 values/styles   用法：R.style.picture.white.style
                    .maxSelectNum(obj.getInt("max"))// 最大图片选择数量
                    .minSelectNum(1)// 最小选择数量
                    .imageSpanCount(obj.getInt("spanCount"))// 每行显示个数
                    .selectionMode(obj.getInt("max")>1? PictureConfig.MULTIPLE :PictureConfig.SINGLE)// 多选 or 单选
                    .previewImage(true)// 是否可预览图片
                    .previewVideo(true)// 是否可预览视频
                    .enablePreviewAudio(true) // 是否可播放音频
                    .isCamera(obj.getBoolean("enableCamera"))// 是否显示拍照按钮
//                            .isZoomAnim(obj.getBoolean("enableZoomAnim"))// 图片列表点击 缩放效果 默认true
                    //.imageFormat(PictureMimeType.PNG)// 拍照保存图片格式后缀,默认jpeg
//                    .setOutputCameraPath("/CustomPath")// 自定义拍照保存路径
                    .enableCrop(obj.getBoolean("enableCrop"))// 是否裁剪
                    .compress(obj.getBoolean("enableCompress"))// 是否压缩
//                            .synOrAsy(obj.getBoolean("enableSync"))//同步true或异步false 压缩 默认同步
                    .compressSavePath(obj.getString("compressSavePath"))//压缩图片保存地址
                    //.sizeMultiplier(0.5f)// glide 加载图片大小 0~1之间 如设置 .glideOverride()无效
                    .glideOverride(160, 160)// glide 加载宽高，越小图片列表越流畅，但会影响列表图片浏览的清晰度
//                        .withAspectRatio(aspect_ratio_x, aspect_ratio_y)// 裁剪比例 如16:9 3:2 3:4 1:1 可自定义
//                            .hideBottomControls(!obj.getBoolean("enableBottomControls"))// 是否显示uCrop工具栏，默认不显示
//                            .isGif(obj.getBoolean("displayGif"))// 是否显示gif图片
                    .freeStyleCropEnabled(true)// 裁剪框是否可拖拽
                    .circleDimmedLayer(obj.getBoolean("enableCircleDimmedLayer"))// 是否圆形裁剪
//                        .showCropFrame(cb_showCropFrame.isChecked())// 是否显示裁剪矩形边框 圆形裁剪时建议设为false
//                        .showCropGrid(cb_showCropGrid.isChecked())// 是否显示裁剪矩形网格 圆形裁剪时建议设为false
//                        .openClickSound(cb_voice.isChecked())// 是否开启点击声音
//                        .selectionMedia(selectList)// 是否传入已选图片
                    //.isDragFrame(false)// 是否可拖动裁剪框(固定)
//                        .videoMaxSecond(15)
//                        .videoMinSecond(10)
                    .previewEggs(true)// 预览图片时 是否增强左右滑动图片体验(图片滑动一半即可看到上一张是否选中)
                    //.cropCompressQuality(90)// 裁剪压缩质量 默认100
                    .minimumCompressSize(100)// 小于100kb的图片不压缩
                    //.cropWH()// 裁剪宽高比，设置如果大于图片本身宽高则无效
                    //.rotateEnabled(true) // 裁剪是否可旋转图片
                    .scaleEnabled(true)// 裁剪是否可放大缩小图片
                    .videoQuality(obj.getInt("quality"))// 视频录制质量 0 or 1
                    //.videoSecond()//显示多少秒以内的视频or音频也可适用
                    .recordVideoSecond(obj.getInt("recordVideoSecond"))//录制视频秒数 默认60s
                    .forResult(PictureConfig.CHOOSE_REQUEST);//结果回调onActivityResult code
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
    public void getThumbnail(JSONObject obj, MethodChannel.Result result) throws JSONException {
        final String path = obj.getString("path");
        boolean sdcard = path.startsWith("/") && path.contains(Environment.getExternalStorageDirectory().getAbsolutePath());
        if (sdcard) {
            thumbnail(path, false, result);
            return;
        }
        thumbnail(path, true, result);
    }
    private File thumbnail() {
        File file;
        if (Environment.isExternalStorageEmulated()) {
            file = _registrar.activity().getExternalFilesDir("attachment");
        } else {
            file = new File(_registrar.activity().getFilesDir(), "attachment");
        }
        if (file != null && !file.exists()) {
            file.mkdirs();
        }
        return file;
    }

    private void thumbnail(String url, boolean isFromNet, MethodChannel.Result result) {
        try {
            String p = new File(url).getName();
            if (p.contains(".")) {
                p = p.substring(0, p.lastIndexOf("."));
            }
            File file = new File(thumbnail(), p + ".jpg");//为原图path
            if (new File(p).exists()) {
                HashMap<String,Object> m = new HashMap<>();
                m.put("path",file.getAbsolutePath());
                result.success(m);
                return;
            }
            file.createNewFile();
            MediaMetadataRetriever retriever = new MediaMetadataRetriever();
//                    if (isFromNet) {
//                        retriever.setDataSource(url, new HashMap<String, String>());
//                    } else {
            retriever.setDataSource(url);
            // }
            Bitmap bitmap = retriever.getFrameAtTime(0);
            if (bitmap != null) {
                FileOutputStream outputStream = new FileOutputStream(file);
                bitmap.compress(Bitmap.CompressFormat.JPEG, 100, outputStream);
                outputStream.close();
                HashMap<String,Object> m = new HashMap<>();
                m.put("path",file.getAbsolutePath());
                result.success(m);
            }
        } catch (Throwable e) {
            System.out.println(e.getMessage());
            result.success(false);
        }
    }
}
