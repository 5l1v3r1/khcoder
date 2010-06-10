# �֥ƥ����ȥե�������ѷ���->��HTML����CSV���Ѵ��ץ��ޥ�ɤΤ���Υ����å�
# Usage:
# 	mysql_csvout->exec(
# 		tani => h1 | h2 | h3 ...
# 		file => '�񤭽Ф��ե�����'
# 	);

package mysql_html2csv;
use strict;

use mysql_exec;
use mysql_getdoc;

sub exec{
	my $class = shift;
	my %args  = @_;
	
	# ¸�ߤ��븫�Ф��Υ����å�
	my @h = ();
	foreach my $i ("h1", "h2", "h3", "h4", "h5"){
		if ($args{tani} eq $i) {last;}
		if (
			mysql_exec->select(
				"select status from status where name = \'$i\'",1
			)->hundle->fetch->[0]
		){
			push @h ,$i;
		}
	}

	# �񤭽Ф��ѥե�����򥪡��ץ�
	open (CSVO,">$args{file}") or 
		gui_errormsg->open(
			type => 'file',
			thefile => $args{file}
		);

	my $h = mysql_exec->select ("
		select *
		from bun_r, bun
		where
			bun_r.id = bun.id
		order by bun.id
	",1)->hundle;
	
	my $current; my %h;
	my $last = 0;
	my $the_tani;
	if ($args{tani} eq 'bun'){
		$the_tani = 'id';
	} else {
		$the_tani = "$args{tani}"."_id";
	}
	use kh_csv;
	while (my $i = $h->fetchrow_hashref){
		if ($i->{"$args{tani}"."_id"}){           # ��ʸ�ξ��
			# print "$i->{$the_tani},";
			if ($i->{$the_tani} == $last){             # �Ѥ�­��
				$current .= $i->{rowtxt};
			} else {                                   # �񤭽Ф���Ϣ³��
				unless (length($current)){
					$last = $i->{$the_tani};
					$current = $i->{rowtxt};
					next;
				}
				
				foreach my $g (@h){
					print CSVO kh_csv->value_conv($h{$g}).',';
				}
				print CSVO kh_csv->value_conv($current)."\n";
				
				$last = $i->{$the_tani};
				$current = $i->{rowtxt};
			}
		} else {                                  # ��̸��Ф��ξ��
			if ( length($current) ){                   # �񤭽Ф��ʸ��Ф��Ѳ���
				foreach my $g (@h){
					print CSVO kh_csv->value_conv($h{$g}).',';
				}
				print CSVO kh_csv->value_conv($current)."\n";
				$current = '';
			}
			$last = 0;
			foreach my $g (reverse @h){                # ���Ф����ѹ�
				if ( $i->{"$g"."_id"} ){
					$h{$g} = $i->{rowtxt};
					last;
				}
			}
		}
	}
	
	# �Ǹ�Υǡ�����񤭽Ф�
	foreach my $g (@h){
		print CSVO "$h{$g},";
	}
	print CSVO "$current\n";
	close (CSVO);
	
	if ($::config_obj->os eq 'win32'){
		kh_jchar->to_sjis($args{file});
	}
}

1;