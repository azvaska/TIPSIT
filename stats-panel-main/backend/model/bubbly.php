<?php
require_once "db.php";

class Bubbly
{
    /*
    CREATE TABLE public."user" (
    email character varying(320) NOT NULL,
    hashed_password character varying(1024) NOT NULL,
    is_active boolean NOT NULL,
    is_superuser boolean NOT NULL,
    is_verified boolean NOT NULL,
    id uuid NOT NULL,
    username character varying,
    name character varying,
    surname character varying,
    phone character varying(20),
    is_phone_verified boolean NOT NULL,
    is_email_verified boolean NOT NULL,
    birth_date date,
    gender public.gender,
    bio character varying(400),
    emoji character varying,
    avatar character varying(100)
    );
     */

    public $email, $is_active, $is_superuser, $is_verified, $id, $username, $name, $surname, $phone, $is_phone_verified, $is_email_verified, $birth_date, $gender, $bio, $emoji, $avatar;
    public function __construct($email, $is_active, $is_superuser, $is_verified, $id, $username, $name, $surname, $phone, $is_phone_verified, $is_email_verified, $birth_date, $gender, $bio, $emoji, $avatar)
    {
        $this->email = $email;
        $this->is_active = $is_active;
        $this->is_superuser = $is_superuser;
        $this->is_verified = $is_verified;
        $this->id = $id;
        $this->username = $username;
        $this->name = $name;
        $this->surname = $surname;
        $this->phone = $phone;
        $this->is_phone_verified = $is_phone_verified;
        $this->is_email_verified = $is_email_verified;
        $this->birth_date = $birth_date;
        $this->gender = $gender;
        $this->bio = $bio;
        $this->emoji = $emoji;
        $this->avatar = $avatar;
    }
    public static function getUser($id)
    {
        $conn = DB::connect_relational2();

        $query = "SELECT email,is_active,is_verified,id,username,name,surname,phone,is_phone_verified,is_email_verified,is_superuser,birth_date,gender,bio,emoji,avatar FROM public.user WHERE id='$id'";

        $result = pg_query($conn, $query);
        if (!$result) {
            echo "An error occurred.\n";
            exit;
        }
        $res = array();
        //add check for empty result
        $row = pg_fetch_assoc($result);
        $tmp = new Bubbly(email:$row['email'], is_active:$row['is_active'], is_superuser:$row['is_superuser'], id:$row['id'], is_verified:$row['is_verified'], username:$row['username'], name:$row['name'], surname:$row['surname'], phone:$row['phone'], is_phone_verified:$row['is_phone_verified'], is_email_verified:$row['is_email_verified'], birth_date:$row['birth_date'], gender:$row['gender'], bio:$row['bio'], emoji:$row['emoji'], avatar:$row['avatar']);
        return json_encode($tmp);
    }

    public static function getUsername($id)
    {
        $conn = DB::connect_relational2();

        $query = "SELECT username FROM public.user WHERE id='$id'";

        $result = pg_query($conn, $query);
        if (!$result) {
            echo "An error occurred.\n";
            exit;
        }
        $res = array();
        //add check for empty result
        $row = pg_fetch_assoc($result);
        return ['username'=>$row['username']];
    }
    


    public static function getListUsers($start,$offset)
    {
        $conn = DB::connect_relational2();

        $query = "SELECT id,username,name,surname FROM public.user limit $offset offset $start";

        $result = pg_query($conn, $query);
        if (!$result) {
            echo "An error occurred.\n";
            exit;
        }
        $res = array();
        //add check for empty result
        while ($row = pg_fetch_assoc($result)) {
            $res[] = ['id'=>$row['id'],
            'username'=>$row['username'],
            'name'=>$row['name'],
            'surname'=>$row['surname']];
        }
        return $res;
    }
    public static function banUser($id)
    {
        $conn = DB::connect_relational2();

        $query = "UPDATE public.user SET is_active=false WHERE id='$id'";

        $result = pg_query($conn, $query);
        if (!$result) {
            echo "An error occurred.\n";
            exit;
        }
        echo "Ok";
    }
    public static function unbanUser($id)
    {
        $conn = DB::connect_relational2();

        $query = "UPDATE public.user SET is_active=true WHERE id='$id'";

        $result = pg_query($conn, $query);
        if (!$result) {
            echo "An error occurred.\n";
            exit;
        }
        echo "Ok";
    }
    public static function search_user_username($query,$offset,$limit)
    {
            $conn = DB::connect_relational2();
    
            $query = "SELECT id,username,name,surname FROM public.user WHERE username ilike '$query%' limit $limit offset $offset";
    
            $result = pg_query($conn, $query);
            if (!$result) {
                echo "An error occurred.\n";
                exit;
            }
            $res = array();
            //add check for empty result
            while ($row = pg_fetch_assoc($result)) {
                $res[] = ['id'=>$row['id'],
                'username'=>$row['username'],
                'name'=>$row['name'],
                'surname'=>$row['surname']];
            }
            return $res;
    }
}
