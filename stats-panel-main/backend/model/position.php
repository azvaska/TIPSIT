<?php
require_once "db.php";
class Position implements JsonSerializable
{
    public $lat, $lng, $userid, $timestamp;

    public function __construct($lat, $lng, $timestamp, $userid = null)
    {
        $this->lat = $lat;
        $this->lng = $lng;
        $this->timestamp = $timestamp;
        $this->userid = $userid;
    }
    public function jsonSerialize(): mixed
    {
        $data = [
            'lat' => $this->lat,
            'lng' => $this->lng,
            'timestamp' => $this->timestamp,
        ];
        if ($this->userid != null) {
            $data['userid'] = $this->userid;
        }

        return $data;
    }
    public static function get_all_positions_smooth($start, $end)
    {
        $conn = DB::connect_db();
        $date_start = new MongoDB\BSON\UTCDateTime($start);
        $date_end = new MongoDB\BSON\UTCDateTime($end);

        $query = new MongoDB\Driver\Query([
            'timestamp' => ['$gte' => $date_start, '$lte' => $date_end],
        ]);

        $cursor = $conn->executeQuery('positions.positions', $query);
        $res = [];
        // Convert cursor to Array and print result
        foreach ($cursor as $id => $value) {
            $res[] = [$value->geo_point->coordinates[1], $value->geo_point->coordinates[0], $value->timestamp->toDateTime()->getTimestamp()];
        }
        // return json_encode(smoothPositions($res,0.2));
        return json_encode($res);
    }
    public static function get_position_smooth_user($start, $end, $user)
    {
        $conn = DB::connect_db();
        $date_start = new MongoDB\BSON\UTCDateTime($start);
        $date_end = new MongoDB\BSON\UTCDateTime($end);


        $query = new MongoDB\Driver\Query([
            'timestamp' => ['$gte' => $date_start, '$lte' => $date_end],
            'user_id' => $user
        ]);

        $cursor = $conn->executeQuery('positions.positions', $query);
        $res = [];
        // Convert cursor to Array and print result
        foreach ($cursor as $id => $value) {
            $res[] = [$value->geo_point->coordinates[1], $value->geo_point->coordinates[0]];
        }
        // return json_encode(smoothPositions($res,0.2));
        return json_encode($res);
    }


    public static function average_travel($start, $end)
    {
        $conn = DB::connect_relational();
        $result = $conn->query("SELECT BIN_TO_UUID(user_id) as user_id, average FROM avgtravel");
        if ($result->num_rows > 0) {
            while ($value = $result->fetch_assoc()) {
                $dist_per_user[] = [$value["user_id"] => $value["average"]];
            }
        }
        $conn->close();
        return $dist_per_user;
    }


    public static function get_max_user_positions($limit = 15)
    {
        /* db.getCollection('positions').aggregate(
            [ {$group : { _id : '$user_id', count : {$sum : 1}}},{
                $sort: {
                    count: -1
                }
            } ]
        ) */
        $conn = DB::connect_db();
        $redis = DB::connect_cache();
        $now = new DateTime();
        $last_update_str = $redis->HGET("n_position", "last_update");
        $last_update = DateTime::createFromFormat('Y-m-d H:i:s', $last_update_str);
        $serialized = $now->format('Y-m-d H:i:s');
        $res = [];
        $command = new MongoDB\Driver\Command([
            'aggregate' => 'positions',
            'pipeline' => [
                [
                    '$group' =>
                    ['_id' => '$user_id', 'count' => array('$sum' => 1)]
                ],
                ['$sort' => ['count' => -1]]
            ],
            'cursor' => new stdClass,
            // 'pipeline' => ['$group' => ['_id' => '$user_id', 'count' => array('$sum' => 1)], '$sort' => ['count' => -1]],
            //    'explain' => true,
        ]);
        if ($last_update instanceof DateTime) {
            if ($now->diff($last_update)->i > 3) {
                $cursor = $conn->executeCommand('positions', $command);
                $res = [];
                // Convert cursor to Array and print result
                foreach ($cursor as $collection) {
                    // var_dump($collection);
                    $tmp = [$collection->_id, $collection->count];
                    $redis->HSET("n_position", $collection->_id, $collection->count);
                    $res[] = $tmp;
                }
                $redis->HSET("n_position", "last_update", $serialized);
                // echo json_encode($redis->HGETALL("n_position"));
            }
        } else {
            $cursor = $conn->executeCommand('positions', $command);
            // Convert cursor to Array and print result
            foreach ($cursor as $collection) {
                // var_dump($collection);
                $tmp = [$collection->_id, $collection->count];
                $redis->HSET("n_position", $collection->_id, $collection->count);
                $res[] = $tmp;
            }
            $redis->HSET("n_position", "last_update", $serialized);
        }
        $values = $redis->HGETALL("n_position");
        arsort($values);
        foreach ($values as $x => $x_value) {
            if ($x != "last_update") {
                $res[] = [$x, $x_value];
            }
        }
        echo json_encode(array_slice($res, 0, $limit));
    }
}
