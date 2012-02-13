package p3_unidic_hukugo0_te;  # �����ιԤϥե�����̾�ˤ��碌���ѹ�
use strict;                    # ���ե������ʸ�������ɤ�EUC��侩

#--------------------------#
#   ���Υץ饰���������   #

sub plugin_config{
	return {
		                                             # ��˥塼��ɽ�������̾��
		name     => 'TermExtract������',
		menu_cnf => 2,                               # ��˥塼������(1)
			# 0: ���ĤǤ�¹Բ�ǽ
			# 1: �ץ������Ȥ�������Ƥ�������м¹Բ�ǽ
			# 2: �ץ������Ȥ�������������äƤ���м¹Բ�ǽ
		menu_grp => 'ʣ���θ��С�UniDic��',        # ��˥塼������(2)
			# ��˥塼�򥰥롼�ײ����������ˤ��������Ԥ���
			# ɬ�פʤ����ϡ�'',�פޤ��ϡ�undef,�פȤ��Ƥ������ɤ���
	};
}

#----------------------------------------#
#   ��˥塼������˼¹Ԥ����롼����   #

sub exec{
	my $self = shift;
	my $mw = $::main_gui->{win_obj};

	gui_window::use_te::unidic->open;

	return 1;
}

#-------------------------------#
#   GUI���Τ���Υ롼����   #

package gui_window::use_te::unidic;
use base qw(gui_window::use_te);
use strict;
use Tk;


sub start{
	my $self = shift;
	
	$self->{text}->insert('1.0',$self->gui_jchar(
		"̾��-���� => ̾��-����̾��-����\n\n"
	));
	$self->{text}->insert('1.0',$self->gui_jchar(
		"̾��-������³ => ̾��-����̾��-���Ѳ�ǽ\n"
	));
	$self->{text}->insert('1.0',$self->gui_jchar(
		"̾��-����-���� => ������-̾��Ū-����\n"
	));
	$self->{text}->insert('1.0',$self->gui_jchar(
		"̾��-����-������³ => ������-̾��Ū-���Ѳ�ǽ\n"
	));
	$self->{text}->insert('1.0',$self->gui_jchar(
		"����-����ե��٥å� => ����-ʸ��\n"
	));
	$self->{text}->insert('1.0',$self->gui_jchar(
		"̾��-����ư��촴 => ̾��-����̾��-�������ǽ��̾��-����̾��-���ѷ������ǽ\n"
	));
	$self->{text}->insert('1.0',$self->gui_jchar(
		"̾��-����-����ư��촴 => ������-̾��Ū-�������ǽ\n"
	));
	$self->{text}->insert('1.0',$self->gui_jchar(
		"̾��-�ʥ����ƻ�촴 => �ʳ����ʤ���\n"
	));

	$self->{text}->insert('1.0',$self->gui_jchar("���ܥ��ޥ�ɤǤϡ���TermExtract�פ�UniDic���б������뤿��˲��Ѥ����С���������Ѥ��ޤ����ʲ��Τ褦���ʻ�̾���ɤ��ؤ�����Ѥ�ԤäƤ��ޤ���\n"),'red');

}

sub _exec{
	my $self = shift;
	# �����¹�
	my $if_exec = 1;
	if (
		   ( -e $::project_obj->file_HukugoListTE)
		&& ( mysql_exec->table_exists('hukugo_te') )
	){
		my $t0 = (stat $::project_obj->file_target)[9];
		my $t1 = (stat $::project_obj->file_HukugoListTE)[9];
		#print "$t0\n$t1\n";
		if ($t0 < $t1){
			$if_exec = 0; # ���ξ��������Ϥ��ʤ�
		}
	}
	
	if ($if_exec){
		my $ans = $::main_gui->mw->messageBox(
			-message => gui_window->gui_jchar
				(
				   "���֤Τ����������¹Ԥ��褦�Ȥ��Ƥ��ޤ���"
				   ."������������û���֤ǽ�λ���ޤ���\n".
				   "³�Ԥ��Ƥ�����Ǥ�����"
				),
			-icon    => 'question',
			-type    => 'OKCancel',
			-title   => 'KH Coder'
		);
		unless ($ans =~ /ok/i){ return 0; }
		
		use mysql_hukugo_te;
		
		my $temp = \&TermExtract::Chasen::get_noun_frq;
		*TermExtract::Chasen::get_noun_frq = \&get_noun_frq_unidic;
		
		my $w = gui_wait->start;
		mysql_hukugo_te->run_from_morpho;
		$w->end;
		
		*TermExtract::Chasen::get_noun_frq = $temp;
	}
	$self->close;
	gui_window::use_te_g->open;
}

sub get_noun_frq_unidic {
    my $self = shift;
    my $data = shift;           # ���ϥǡ���
    my $mode = shift || 0;      # ���ϥǡ������ե����뤫���ѿ����μ����ѥե饰
    my %cmp_noun_list = ();     # ʣ�������پ�������줿�ϥå���ʴؿ�������͡�
    my @input = ();             # �����ǲ��Ϸ�̤�����
    my $must  = 0;              # ���θ줬̾��Ǥʤ���Фʤ�ʤ����Ͽ�
    my @terms = ();             # ʣ���ꥹ�Ⱥ����Ѥκ��������
    my @unknown = ();           # ��̤�θ�������Ѻ���ѿ�
    my @alphabet = ();          # ����ե��٥å������Ѻ���ѿ�

    $self->IsAgglutinativeLang; # ����������ñ��֣��������ʤ���

    # �����Ѹ�ꥹ�Ȥء����������ɲä��륵�֥롼����
    my $add = sub {
        my $terms         = shift;
        my $cmp_noun_list = shift;

        # ��Ƭ�����פʸ�κ��
        if (defined $terms->[0]) {
            shift @$terms if $terms->[0] eq '��';
        }
        # ������;ʬ�ʸ�κ��
        if (defined $terms->[0]) {
            my $end = $terms->[$#$terms];
            if ( $end eq '�ʤ�'  || $end eq '��'   || $end eq '��'       || 
                 $end eq '��'    || $end eq '��'   || $end eq '��'       ||
                 $end eq '��'    || $end eq '��'   || $end eq '��'       ||
                 $end =~ /^\s+$/ || $must) 
                { pop @$terms }
        }
        $cmp_noun_list->{ join ' ', @$terms }++ if defined $terms->[0];
        @$terms  = ();
    };

    # ���Ϥ���˥ե�����Ȳ��ꤷ���絬�ϥե�����ˤ��б��Ǥ���褦���ե�����
    # ���Ƥ�1�Ԥ����ɤ߹���ǽ�������褦���ѹ��������̰� 2008 02/05��
    # print "TermExtract::Chasen Over-writed! (kh)\n";

    # ���Ϥ��ե�����ξ��
    #if ($mode ne 'var') {                                       # higuchi
    #    local($/) = undef;                                      # higuchi
    #    open (IN, $data) || die "Can not open input file. $!";  # higuchi
    #    $data = <IN>;                                           # higuchi
    #    close IN;                                               # higuchi
    #}                                                           # higuchi

    # ñ̾���Ϣ�����
    # foreach my $morph ((split "\n", $data)) {                  # higuchi
    open (IN, $data) || die "Can not open input file. $!";       # higuchi
    while (<IN>){                                                # higuchi
        my $morph = $_;                                          # higuchi
        chomp $morph;
	    my ($noun, $part_of_speach) = (split(/\t/, $morph))[0,3];
        $part_of_speach = "" unless defined $part_of_speach;  # �ʻ�

        # ���桦���ͤǶ��ڤ�줿��̤�θ�פϡ����ĤΤޤȤޤ�ˤ��Ƥ������
        #     ����ե��٥å�  �� \x41-\x5A, \x61-\x7A
        if ($part_of_speach eq '̤�θ�' & $noun !~ /^[\(\)\[\]\<\>|\"\'\;\,]/) {
            if (@unknown) {
                # ��̤�θ�פ����桦���ͤǷ�ӤĤ��ʤ�
                unless ($unknown[$#unknown] =~ /[\x41-\x5A|\x61-\x7A]$/ &
                       $noun =~ /^[\x41-\x5A|\x61-\x7A]/) {
                    push @unknown, $noun;  # ��̤�θ�פ�ҤȤޤȤ�ˤ���
                    next;
                }
            }
            else {
                push @unknown, $noun;
                next;
            }
        }
        # ��̤�θ�פκǸ夬����ʤ������
        while (@unknown) {
            if ($unknown[$#unknown] =~ /^[\x21-\x2F]|[{|}:\;\<\>\[\]]$/) {
                pop @unknown;
            }
            else {
            	last;
            }
        }
        push @terms, join "", @unknown  if @unknown;
        @unknown = ();

        # ����-����ե��٥åȤϡ����ĤΤޤȤޤ�ˤ��Ƥ������
        if ($part_of_speach eq '����-ʸ��') {
            push @alphabet, $noun;
            next;
        }
        push @terms, join "", @alphabet  if @alphabet;
        @alphabet = ();

        if( $part_of_speach eq '̾��-����̾��-����'                      ||
            $part_of_speach eq '̾��-����̾��-���Ѳ�ǽ'                  ||
            $part_of_speach eq '������-̾��Ū-����'                          ||
            $part_of_speach eq '������-̾��Ū-���Ѳ�ǽ'                      ||
            $part_of_speach eq '����-ʸ��'                     ||
            $part_of_speach =~ /̾��\-��ͭ̾��/                          ||
            $part_of_speach eq '̤�θ�' & 
                               $noun !~ /^[\x21-\x2F]|[{|}:\;\<\>\[\]]$/
          ){
            if ($part_of_speach eq '̤�θ�' & $noun =~ /.,$/) {
                chop $noun;
                push @terms, $noun if $noun ne "";
                &$add(\@terms, \%cmp_noun_list) unless $must;
            }
            else {
                push @terms, $noun;
            }
            $must = 0; next;
        }
        elsif(($part_of_speach eq '̾��-����̾��-�������ǽ' | 
               $part_of_speach eq '̾��-����̾��-���ѷ������ǽ')
           ){
            push @terms, $noun;
            $must = 1; next;
        }
        elsif($part_of_speach eq '������-̾��Ū-�������ǽ' & @terms){
            push @terms, $noun;
            $must = 1; next;
        }
        elsif($part_of_speach =~ /^ư��/){
            @terms = ();
        }
        else {
            &$add(\@terms, \%cmp_noun_list) unless $must;
        }
        @terms = () if $must;
        $must = 0;
    }
    close IN;                                                    # higuchi

    return \%cmp_noun_list;
}


1;
