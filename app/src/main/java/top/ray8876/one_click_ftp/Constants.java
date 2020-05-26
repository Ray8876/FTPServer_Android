package top.ray8876.one_click_ftp;

import top.ray8876.one_click_ftp.utils.Storage;

public class Constants {
    public static class SQLConsts{
        public static final String SQL_USERS_FILENAME ="ftp_accounts.db";
        public static final int SQL_VERSION=1;
        public static final String TABLE_NAME="ftp_account_table";
        public static final String COLUMN_ID="_id";
        public static final String COLUMN_ACCOUNT_NAME="name";
        public static final String COLUMN_PASSWORD="password";
        public static final String COLUMN_PATH ="path";
        public static final String COLUMN_WRITABLE ="writable";
    }
    public static class FTPConsts{
        public static final String NAME_ANONYMOUS="anonymous";
    }
    public static class PreferenceConsts{
        public static final String FILE_NAME ="settings";
        /**
         * this stands for a boolean value
         */
        public static final String ANONYMOUS_MODE="anonymous_mode";
        public static final boolean ANONYMOUS_MODE_DEFAULT=true;
        /**
         * this stands for a string value
         */
        public static final String ANONYMOUS_MODE_PATH="anonymous_mode_path";
        public static final String ANONYMOUS_MODE_PATH_DEFAULT=Storage.getMainStoragePath();
        /**
         * this stands for a boolean value
         */
        public static final String ANONYMOUS_MODE_WRITABLE="anonymous_mode_writable";
        public static final boolean ANONYMOUS_MODE_WRITABLE_DEFAULT=false;

        /**
         * this stands for a boolean value
         */
        public static final String WAKE_LOCK="wake_lock";
        public static final boolean WAKE_LOCK_DEFAULT=true;
        /**
         * this stands for a int value
         */
        public static final String PORT_NUMBER="port_number";
        public static final int PORT_NUMBER_DEFAULT=8876;
        /**
         * this stands for a string value
         */
        public static final String CHARSET_TYPE ="charset_type";
        public static final String CHARSET_TYPE_DEFAULT ="UTF-8";
        /**
         * this stands for a int value
         */
        public static final String PORT_NUMBER2="port_number2";
        public static final int PORT_NUMBER2_DEFAULT=8876;
        /**
         * this stands for a string value
         */
        public static final String CHARSET_TYPE2 ="charset_type2";
        public static final String CHARSET_TYPE2_DEFAULT ="UTF-8";
        /**
         * this stands for a int value
         */
        public static final String PORT_NUMBER1="port_number1";
        public static final int PORT_NUMBER1_DEFAULT=8876;
        /**
         * this stands for a string value
         */
        public static final String CHARSET_TYPE1 ="charset_type1";
        public static final String CHARSET_TYPE1_DEFAULT ="UTF-8";
    }

    public static class Charset{
        public static final String CHAR_UTF="UTF-8";
        public static final String CHAR_GBK="GBK";
    }

}
