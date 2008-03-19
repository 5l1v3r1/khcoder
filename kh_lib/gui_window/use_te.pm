package gui_window::use_te;
use base qw(gui_window);
use strict;
use Tk;
use gui_jchar;

# Window�򳫤�
sub _new{
	my $self = shift;
	$self->{win_obj}->title($self->gui_jchar('TermExtract������ˤĤ���','euc'));;

	$self->{win_obj}->Label(
		-text => $self->gui_jchar('�����Ѹ�ʥ�����ɡ˼�ư�����Perl�⥸�塼���TermExtract�פ����Ѥ��ޤ���','euc'),
		-font => "TKFN",
	)->pack(-anchor => 'w',-pady=>'2',-padx=>'2');

	my $f1 = $self->{win_obj}->Frame()->pack(-anchor => 'w');
	$f1->Label(
		-text => $self->gui_jchar('TermExtract��Web�ڡ�����','euc'),
		-font => "TKFN",
	)->pack(-anchor => 'w',-pady=>'2',-padx=>'2', -side => 'left');

	$f1->Button(
		-text => 'http://gensen.dl.itc.u-tokyo.ac.jp/',
		-font => "TKFN",
		-foreground => 'blue',
		-activeforeground => 'red',
		-borderwidth => '0',
		-relief => 'flat',
		-cursor => 'hand2',
		-command => sub{
			$self->{win_obj}->after(
				10,
				sub {
					gui_OtherWin->open('http://gensen.dl.itc.u-tokyo.ac.jp/');
				}
			);
		}
	)->pack(-side => 'left', -anchor => 'w');

	$self->{win_obj}->Label(
		-text => $self->gui_jchar('TermExtract�������','euc'),
		-font => "TKFN",
	)->pack(-anchor => 'w',-pady=>'2',-padx=>'2');

	my $txt = $self->{win_obj}->Scrolled(
		"ROText",
		spacing1 => 3,
		spacing2 => 2,
		spacing3 => 3,
		-scrollbars=> 'osoe',
		-height => 12,
		-width => 64,
		-wrap => 'word',
		-font => "TKFN",
		-background => 'white',
		-foreground => 'black'
	)->pack(-fill => 'both', -expand => 'yes', -pady=>'2',-padx=>'2');
	$txt->bind("<Key>",[\&gui_jchar::check_key,Ev('K'),\$txt]);
	$txt->bind("<Button-1>",[\&gui_jchar::check_mouse,\$txt]);
	$self->{text} = $txt;

	
	$self->{win_obj}->Button(
		-text => $self->gui_jchar('����󥻥�'),
		-font => 'TKFN',
		-width => 8,
		-command => sub{
			$self->{win_obj}->after(10,sub{$self->close;})
		}
	)->pack(-anchor=>'e',-side => 'right',-padx => 2, -pady => 2);

	my $ok_btn = $self->{win_obj}->Button(
		-text  => 'OK',
		-font  => 'TKFN',
		-width => 8,
		-command => sub{ $self->{win_obj}->after
			(
				10,
				sub {
					$self->close;
					# �����¹�
					my $if_exec = 1;
					if (-e $::project_obj->file_HukugoListTE){
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
						
						my $w = gui_wait->start;
						use mysql_hukugo_te;
						mysql_hukugo_te->run_from_morpho;
						$w->end;
						
					}
					gui_window::use_te_g->open;
				}
			);
		}
	)->pack(-anchor => 'e',-side => 'right',  -pady => 2);
	
	$self->put_info;
	$ok_btn->focus;
	return $self;
}

# ��������ή������
sub put_info{
	my $self = shift;
	$self->{text}->tagConfigure('red',
		-foreground => 'red',
		-background => 'white',
		-underline  => 0
	);
	
	$self->{text}->insert('end',$self->gui_jchar("��TermExtract�פϡ������ؾ�����ץ��󥿡��޽���ŻҲ����硦����漼�ˤƸ�������Ƥ��ޤ����ܺ٤ϰʲ����̤�Ǥ���\n") );
	
	$self->{text}->insert('end',"TermExtract::Calc_Imp.pm:\n",'red');
	my $Calc_Imp_cr = '�����Υץ����ϡ������ء�����͵�ֶ��������͹�Ω��ء���ä§�����������������������Ѹ켫ư��Х����ƥ�פ�Extract.pm�򻲹ͤˡ�������ζ���������������饳���ǥ��󥰤�ľ������ΤǤ��롣
�����κ�Ȥϡ������ء�����ϯ(maeda@lib.u-tokyo.ac.jp)���Ԥä���
�����κݤΥ��󥻥ץȤϼ��ΤȤ��ꡣ
���������ǲ��ϥǡ����μ����ߤ�ޤ�ƥ⥸�塼�벽����¾�Υץ����ؤ��Ȥ߹��ߤ��Ǥ��뤳��
�����ؽ���ǽ��Ϣ�ܸ����׾����DB�ؤ����ѤȤ��γ��ѡˤ���Ĥ���
���������ٷ׻���ˡ���ڤ��ؤ����Ǥ��뤳��
�������ܸ�ѥå������Ƥ�Perl (Jperl) �����ǤϤʤ������ꥸ�ʥ��Perl��ư��뤳��
�����������γ��ݤΤ���Perl��strict�⥸�塼��ڤ�perl��-w���ץ������б����뤳��
��������ؿ��פˤ�롢���׸�κ���롼�����Ȥ�Ϥ�������
����ñ̾���Ϣ�ܲ�������ʿ�Ѥ��������Ȥ뤳�ȡ�Extract.pm��Ϣ�ܲ���Σ��������٤Ȥ��Ƥ������ʤ�����������ϥѥ��᡼���ˤ��Ĵ���Ǥ��롣Extract.pm��Ʊ���ˤ���ˤϡ�$obj->average_rate(0.5) �Ȥ���
�������ͤ�Ǥ�դθ������ٷ׻����оݤ���Ϥ�����褦�ˤ��뤳��
����¿������б����뤿�ᡢUnicode(UTF-8)��ư��뤳��
�������ѡ��ץ쥭���ƥ��򸵤˽����ٷ׻���Ԥ���褦�ˤ��뤳�ȡ�
������Frequency, TF, TF*IDF�ʤɤν����ٷ׻���ǽ����Ĥ���

Extract.pm �κ�Ԥϼ��ΤȤ��ꡣ
��Keisuke Uchima 
��Hirokazu Ohata
��Hiroaki  Yumoto (Email:hir@forest.dnj.ynu.ac.jp)

�ʤ����ܥץ����λ��Ѥˤ����������������ʤ��̤˴ؤ��Ƥ������Ǥϰ�����Ǥ�����ʤ���';
	$self->{text}->insert('end',$self->gui_jchar($Calc_Imp_cr) );

	$self->{text}->insert('end',"\n\nTermExtract::Chasen.pm:\n",'red');
	my $Chasen = '�����Υץ����ϡ������ء�����͵�ֶ��������͹�Ω��ء���ä§�����������������������Ѹ켫ư��Х����ƥ�פ�termex.pl �򻲹ͤ˥����ɤ�����Ū�˽�ľ������ΤǤ��롣
�����κ�Ȥϡ������ء�����ϯ (maeda@lib.u-tokyo.ac.jp)���Ԥä���
��������ϼ��ΤȤ��ꡣ
������Ω����������ץȤ���⥸�塼��ؽ񤭴�����¾�Υץ���फ����Ȥ߹��ߤ��ǽ�Ȥ�����
���������ǲ��ϺѤߤΥƥ����ȥե���������ǤϤʤ����ѿ���������ϲ�ǽ�ˤ���������ˤ��UNIX�Ķ��Ǥ� Text::Chasen �⥸�塼�����ˤ��б�����ǽ�ˤʤä���
�������ꥸ�ʥ�Perl�б��ˤ�����Shift-JIS��EUC�ˤ�����ܸ����Ϥ����ܸ��б��ѥå������Ƥ�Perl(Jperl)��Ȥ鷺�Ȥ������ǽ�ˤʤä���
������˸�ͭ̾�������Ȥ�����ʸ���������Ȥ���褦�ѥ�᡼������ꤷ��
�������Σ�ʸ���Ρ�̤�θ�פϸ�ζ��ڤ�Ȥ���ǧ������褦�ˤ������ޤ�����̤�θ�פ� , �ǽ����Ȥ��ˤ��ζ��ڤ�Ȥ�����!"#$%&\'()*+,-./{|}:;<>[]
����ʣ���Ρ�̤�θ�פ���ñ̾�������������å����Ȥ߹�������ʡ���䦡�ver 2.3.3���ο������С������ؤ��б���
����ʣ���Ρֵ���-����ե��٥åȡפ����ñ�������������å����Ȥ߹�������ʡ���䦡�ver 2.3.3���ο������С������ؤ��б���
�����������γ��ݤΤ��ᡢPerl��"strict"�⥸�塼��ڤ�perl��-w���ץ����ؤ��б���Ԥä���

�ʤ����ܥץ����λ��Ѥˤ����������������ʤ��̤˴ؤ��Ƥ������Ǥϰ�����Ǥ�����ʤ���';
	$self->{text}->insert('end',$self->gui_jchar($Chasen) );

	return $self;
}

sub win_name{
	return 'w_use_te';
}

1;
