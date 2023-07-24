<?php
		// Linux CPU
		$load = sys_getloadavg();
		// Linux MEM
		$free = shell_exec('free');
		$free = (string)trim($free);
		$free_arr = explode("\n", $free);
		$mem = explode(" ", $free_arr[1]);
		$mem = array_filter($mem, function($value) { return ($value !== null && $value !== false && $value !== ''); }); // removes nulls from array
		$mem = array_merge($mem); // puts arrays back to [0],[1],[2] after 
		$memtotal = round($mem[1] / 1000000,2);
		$memused = round($mem[2] / 1000000,2);
		$memfree = round($mem[3] / 1000000,2);
		$memshared = round($mem[4] / 1000000,2);
		$memcached = round($mem[5] / 1000000,2);
		$memavailable = round($mem[6] / 1000000,2);

	//$memusage = round(($memavailable/$memtotal)*100);
	$memusage = round(($memused/$memtotal)*100);		
    $cpu = floatval(shell_exec('top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk \'{print 100 - $1}\' | tr -d \'\n\''));

	// use servercheck.php?json=1
	echo json_encode(array("ram"=>$memusage,"cpu"=>$cpu,
	"memtotal"=>$memtotal,"memused"=>$memused,"memfree"=>$memfree,
	"memshared"=>$memshared,"memcached"=>$memcached,"memavailable"=>$memavailable,
));
?>
