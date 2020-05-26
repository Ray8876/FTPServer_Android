package top.ray8876.one_click_ftp.data;

import androidx.annotation.NonNull;

import org.json.JSONObject;

import top.ray8876.one_click_ftp.utils.Storage;

import java.io.Serializable;

public class AccountItem implements Serializable{
    public long id=-1;
    public String account="";
    public String password="";
    public String path= Storage.getMainStoragePath();
    public boolean writable=false;

    @NonNull
    @Override
    public String toString() {
        try {
            JSONObject _obj = new JSONObject();
            _obj.put("id", id);
            _obj.put("account", account);
            _obj.put("password", password);
            _obj.put("path", path);
            _obj.put("writable", writable);
            return _obj.toString();

        } catch (Exception e) {
            return e.toString();
        }

    }
}
