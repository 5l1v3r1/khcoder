package mysql_getdoc;
use strict;
use mysql_exec;

use mysql_getdoc::dan;

sub get{
	my $class = shift;
	my %args  = @_;
	my $self = \%args;
	$class .= '::'."$args{tani}";
	bless $self, $class;

	# ʸ�������
	unless ( defined($self->{doc_id}) ){
		$self->{doc_id} = $self->get_doc_id;
		print "doc_id $self->{doc_id}";
	}
	
	# ��ʸ�μ��Ф�
	my $d = $self->get_body;
	my %w_search = ();                            # �����춯Ĵ�ν���
	foreach my $i (@{$self->{w_search}}){
		$w_search{$i} = 1;
	}
	my @body = (); my $last;                      # �����ղá������춯Ĵ
	foreach my $i (@{$d}){
		unless ($i->[2] == $last){
			$last = $i->[2];
			push @body, ["\n",''];
		}
		my $k = ''; if ($w_search{$i->[1]}){$k = "search";}
		push @body, [Jcode->new("$i->[0]")->sjis, $k];
	}
	$self->{body} = \@body;
	
	# ��̸��Ф��μ��Ф�
	$self->{header} = $self->get_header;
	
	
	return $self;
}


#----------------------#
#   ��̸��Ф��μ���   #

sub get_header{
	my $self = shift;
	my $tani = $self->{tani};
	my @possible_header = ('h1','h2','h3','h4','h5');
	my $headers = '';
	
	my $id_info = mysql_exec->select("
		SELECT id, h1_id, h2_id, h3_id, h4_id, h5_id
		FROM $tani
		WHERE id = $self->{doc_id}
	",1)->hundle->fetch;

	my %possible;
	foreach my $i (@possible_header){
		if ($i eq $tani){last;}                   # ��̤��ɤ��������å�
		if (                                      # ���������뤫�����å�
			mysql_exec->select(
				"select status from status where name = \'$i\'",1
			)->hundle->fetch->[0]
		){
			print "getting $i header...\n";
			my $sql = "SELECT rowtxt\n";
			$sql   .= "FROM bun, hyosobun\n";
			$sql   .= "WHERE\n";
			$sql   .= "    hyosobun.bun_idt = bun.id\n";
			$sql   .= "    AND bun_id = 0\n";
			$sql   .= "    AND dan_id = 0\n";
			my $frag = 0; my $n = 5;
			foreach my $h ('h5','h4','h3','h2','h1'){
				if ($i eq $h){$frag = 1}
				if ($frag){
					$sql .= "    AND $h"."_id = $id_info->[$n]\n";
				} else {
					$sql .= "    AND $h"."_id = 0\n";
				}
				--$n;
			}
			$sql   .= "LIMIT 1";
			my $h = mysql_exec->select("$sql",1)->hundle->fetch->[0];
			$h = Jcode->new($h)->sjis;
			$headers .= "$h\n";
		}
	}
	return $headers;
}

sub doc_id{
	my $self = shift;
	return $self->{doc_id};
}
sub body{
	my $self = shift;
	return $self->{body};
}
sub header{
	my $self = shift;
	return $self->{header};
}




1;