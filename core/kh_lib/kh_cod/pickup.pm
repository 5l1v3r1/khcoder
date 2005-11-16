# ����ʬ�ƥ����Ȥμ��Ф���->������Υ����ɤ�Ϳ����줿ʸ������ץ��ޥ��
#                                                         �Τ���Υ��å�

package kh_cod::pickup;
use base qw(kh_cod);
use strict;

my $records_per_once = 5000;


sub pick{
	my $self = shift;
	my %args = @_;
	
	use Benchmark;                                    # ���ַ�¬��
	my $t0 = new Benchmark;                           # ���ַ�¬��
	
	# ���礨�������ǥ���
	my $the_code = $self->{codes}[$args{selected}];
	$the_code->ready($args{tani});
	$the_code->code('ct_pickup');
	unless ($the_code->res_table){
		gui_errormsg->open(
			type => 'msg',
			msg  =>
				"���򤵤줿�����ɤϡ��ɤ�ʸ��ˤ�Ϳ�����ޤ���Ǥ�����\n".
				"�ե������������ߤ���ޤ�����"
		);
		return 0;
	}

	# �񤭽Ф�

	open (F,">$args{file}") or 
		gui_errormsg->open(
			thefile => $args{file},
			type    => 'file'
		);

	my $last = 0;
	my $last_seq = 0;
	my $id = 1;
	my $bun_num = mysql_exec->select("SELECT MAX(id) FROM bun")
		->hundle->fetch->[0]; # �ǡ����˴ޤޤ��ʸ�ο�

	while ($id <= $bun_num){
		my $sth = mysql_exec->select(
			$self->sql(
				tani    => $args{tani},
				pick_hi => $args{pick_hi},
				d1      => $id,
				d2      => $id + $records_per_once,
			),
			1
		)->hundle;
		#unless ($sth->rows > 0){
		#	last;
		#}
		$id += $records_per_once;

		while (my $i = $sth->fetchrow_hashref){
			if ($i->{bun_id} == 0 && $i->{dan_id} == 0){    # ���Ф���
				if ($last){
					print F "\n";
					$last = 0;
				}
				print F "$i->{rowtxt}\n";
			} else {
				if ($last == $i->{dan_id}){     # Ʊ�������³��
					if (                  # ʸñ�̤ξ����ü����
						   ($args{tani} eq 'bun')
						&! ($last_seq + 1 == $i->{seq})
					){
						print F "\n$i->{rowtxt}";
						print ".";
					} else {
						print F "$i->{rowtxt}";
						print "-";
					}
				}
				elsif ($i->{dan_id} == 1){      # ������Ѥ���ܡ�1���ܤ������
					print F "\n" if $last;# ľ�������Ф��Ǥʤ���в����ղ�
					print F "$i->{rowtxt}";
					$last = 1;
				} else {                        # ������Ѥ���ܡ�2���ܰʹߡ�
					print F "\n$i->{rowtxt}";
					$last = $i->{dan_id};
				}
			}
			$last_seq = $i->{seq};
		}
		print "$id,";
	}
	close (F);
	my $t1 = new Benchmark;                           # ���ַ�¬��
	print timestr(timediff($t1,$t0)),"\n";            # ���ַ�¬��
	
	if ($::config_obj->os eq 'win32'){
		kh_jchar->to_sjis($args{file});
	}

}

sub sql{
	my $self = shift;
	my %args = @_;
	
	my $sql;
	if ($args{pick_hi}){
		$sql .= "SELECT bun.bun_id, bun.dan_id, bun_r.rowtxt, bun.id as seq\n";
		$sql .= "FROM bun, bun_r\n";
		unless ($args{tani} eq 'bun'){
			$sql .= "	LEFT JOIN $args{tani} ON\n";
			my $flag = 0;
			foreach my $i ('bun','dan','h5','h4','h3','h2','h1'){
				if ($i eq $args{tani}){ ++$flag;}
				if ($flag) {
					if ($flag > 1){
						$sql .="\t\tAND bun.$i"."_id = $args{tani}.$i"."_id\n";
					} else {
						$sql .="\t\t    bun.$i"."_id = $args{tani}.$i"."_id\n";
					}
					++$flag;
				}
			}
		}
		$sql .= "\tLEFT JOIN ct_pickup ON ct_pickup.id = $args{tani}.id\n";
		$sql .= "WHERE\n";
		$sql .= "
			    bun.id = bun_r.id
			AND bun.id >= $args{d1}
			AND bun.id <  $args{d2}
			AND (
				IFNULL(ct_pickup.num,0)
				OR
				(
					    bun.bun_id = 0
					AND bun.dan_id = 0
					AND bun.$args{tani}"."_id  = 0
				)
			)
		";
	} else {
		$sql .= "SELECT bun.bun_id, bun.dan_id, bun_r.rowtxt, bun.id as seq\n";
		if ($args{tani} eq 'bun'){
			$sql .= "FROM bun, bun_r, ct_pickup\n";
		} else {
			$sql .= "FROM bun, bun_r, $args{tani}, ct_pickup\n";
		}
		$sql .= "WHERE\n";
		$sql .= "	    bun.id = bun_r.id\n";
		$sql .= "	AND bun.id >= $args{d1}\n";
		$sql .= "	AND bun.id <  $args{d2}\n";
		$sql .= "	AND ct_pickup.id = $args{tani}.id\n";
		unless ($args{tani} eq 'bun'){
			my $flag = 0;
			foreach my $i ('bun','dan','h5','h4','h3','h2','h1'){
				if ($i eq $args{tani}){$flag=1;}
				if ($flag) {
					$sql .= "\t\tAND bun.$i"."_id = $args{tani}.$i"."_id\n";
				}
			}
		}
	}
	
	return $sql;
}


1;