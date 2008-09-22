package gui_window;

use strict;
use Tk;
use Tk::LabFrame;
use Tk::ItemStyle;
use Tk::DropSite;
require Tk::ErrorDialog;

use gui_wait;
use gui_OtherWin;

use gui_window::main;
use gui_window::about;
use gui_window::project_new;
use gui_window::project_open;
use gui_window::project_edit;
use gui_window::sysconfig;
use gui_window::sql_select;
use gui_window::word_search;
use gui_window::dictionary;
use gui_window::word_ass_opt;
use gui_window::word_ass;
use gui_window::word_conc;
use gui_window::word_conc_opt;
use gui_window::word_conc_coloc;
use gui_window::word_conc_coloc_opt;
use gui_window::word_freq;
use gui_window::word_freq_plot;
use gui_window::word_df_freq;
use gui_window::word_df_freq_plot;
use gui_window::word_tf_df;
use gui_window::word_corresp;
use gui_window::word_cls;
use gui_window::word_mds;
use gui_window::doc_view;
use gui_window::doc_search;
use gui_window::doc_cls;
use gui_window::doc_cls_res;
use gui_window::doc_cls_res_opt;
use gui_window::doc_cls_res_sav;
use gui_window::morpho_check;
use gui_window::morpho_detail;
use gui_window::cod_count;
use gui_window::cod_tab;
use gui_window::cod_outtab;
use gui_window::cod_jaccard;
use gui_window::cod_mds;
use gui_window::cod_cls;
use gui_window::cod_corresp;
use gui_window::cod_out;
use gui_window::txt_html2csv;
use gui_window::txt_pickup;
use gui_window::morpho_crossout;
use gui_window::outvar_read;
use gui_window::outvar_list;
use gui_window::outvar_detail;
use gui_window::force_color;
use gui_window::contxt_out;
use gui_window::datacheck;
use gui_window::use_te;
use gui_window::use_te_g;
use gui_window::hukugo;
use gui_window::r_plot;
use gui_window::r_plot_opt;

BEGIN{
	if( $] > 5.008 ){
		require Encode;
	}
}

sub open{
	my $class = shift;
	my $self;
	my @arg = @_;
	my %arg = @arg;
	$self->{dummy} = 1;
	bless $self, $class;

	my $check = 0;
	if ($::main_gui){
		$check = $::main_gui->if_opened($self->win_name);
	}

	if ( $check ){
		$self = $::main_gui->get($self->win_name);
	} else {
		# Window�����ץ�
		if ($self->win_name eq 'main_window'){
			$self->{win_obj} = MainWindow->new;
		} else {
			$self->{win_obj} = $::main_gui->mw->Toplevel();
			#$self->win_obj->focus;
		}

		# Window��������Υ��å�
		my $icon = $self->win_obj->Photo(
			-file =>   Tk->findINC('acre.gif')
		);
		$self->win_obj->iconimage($icon);
		#$self->win_obj->Icon(-image => $icon);

		# Window�������Ȱ��֤λ���
		my $g = $::config_obj->win_gmtry($self->win_name);
		if ($g and not $arg{no_geometry}){
			$self->win_obj->geometry($g);
		}

		# Window����Ⱥ���
		$self = $self->_new(@arg);
		$::main_gui->opened($self->win_name,$self);

		# Window���Ĥ���ݤΥХ����
		$self->win_obj->bind(
			'<Control-Key-q>',
			sub{ $self->close; }
		);
		$self->win_obj->protocol('WM_DELETE_WINDOW', sub{ $self->close; });

		# �ᥤ��Windows����뤿��Υ������Х����
		$self->win_obj->bind(
			'<Alt-Key-m>',
			sub { $::main_gui->{main_window}->win_obj->focus; }
		);

		# �ü�������б�
		$self->start;

	}
	return $self;
}


sub close{
	my $self = shift;
	$self->end; # �ü�������б�
	$::config_obj->win_gmtry($self->win_name,$self->win_obj->geometry);
	$::config_obj->save;
	$self->win_obj->destroy;
}

sub win_obj{
	my $self = shift;
	return $self->{win_obj};
}

sub end{
	return 1;
}

sub start{
	return 1;
}

#--------------------------#
#   ���ܸ�ɽ�������ϴط�   #
#--------------------------#

sub gui_jchar{ # GUIɽ���Ѥ����ܸ�
	my $char = $_[1];
	my $code = $_[2];
	
	if ( $] > 5.008 ) {
		#return $char if utf8::is_utf8($char);
		
		$code = Jcode->new($char)->icode unless $code;
		# print "$char : $code\n";
		$code = 'eucJP-ms'   if $code eq 'euc';
		$code = 'cp932' if $code eq 'sjis';
		$code = 'cp932' if $code eq 'shiftjis';
		$code = 'eucJP-ms' unless length($code);
		return Encode::decode($code,$char);
	} else {
		if (defined($code) && $code eq 'sjis'){
			return $char;
		} else {
			return Jcode->new($char,$code)->sjis;
		}
	}
}

sub gui_jm{ # ��˥塼�Υȥå���ʬ�����ܸ�
	my $char = $_[1];
	my $code = $_[2];
	
	if ( $] > 5.008 && $::config_obj->os eq 'linux' ) {
		$code = Jcode->new($char)->icode unless $code;
		$code = 'eucJP-ms'   if $code eq 'euc';
		$code = 'cp932' if $code eq 'sjis';
		return Encode::decode($code,$char);
	}
	elsif ($] > 5.008){
		return Jcode->new($char,$code)->sjis;
	} else {
		if (defined($code) && $code eq 'sjis'){
			return $char;
		} else {
			return Jcode->new($char,$code)->sjis;
		}
	}
}

sub gui_jt{ # Window�����ȥ���ʬ�����ܸ� ��Win9x & Perl/Tk 804�Ѥ��ü������
	my $char = $_[1];
	my $code = $_[2];
	$code = '' unless defined($code);
	
	if ( $] > 5.008 ) {
		$code = Jcode->new($char)->icode unless $code;
		# print "$char : $code\n";
		$code = 'eucJP-ms'   if $code eq 'euc';
		$code = 'cp932' if $code eq 'sjis';
		$code = 'cp932' if $code eq 'shiftjis';
		$code = 'eucJP-ms' unless length($code);
		if ( ( $^O eq 'MSWin32' ) and not ( Win32::IsWinNT() ) ){
			if ($code eq 'sjis'){
				return $char;
			} else {
				return Jcode->new($char,$code)->sjis;
			}
		} else {
			return Encode::decode($code,$char);
		}
	} else {
		if ($code eq 'sjis'){
			return $char;
		} else {
			return Jcode->new($char,$code)->sjis;
		}
	}
}


sub gui_jg_filename_win98{ # ����ʸ����ޤ�ѥ��ν��� ��Win9x & Perl/Tk 804�Ѥ��ü������
	my $char = $_[1];
	
	if (
		    ( $] > 5.008 )
		and ( $^O eq 'MSWin32' )
		and not ( Win32::IsWinNT() )
	){
		$char =~ s/\//\\/g;
		$char = Encode::decode('cp932',$char);
		$char = Encode::encode('cp932',$char);
	}
	
	return $char;
}

sub gui_jg{ # ���Ϥ��줿ʸ������Ѵ�
	my $char = $_[1];
	
	if ($] > 5.008){
		if ( utf8::is_utf8($char) ){
			#print "utf8\n";
			return Encode::encode('cp932',$char);
		} else {
			#print "not utf8\n";
			return $char;
		}
	} else {
		return $char;
	}
}

#----------------#
#   ���̤ν���   #
#----------------#

sub disabled_entry_configure{
	my $ent = $_[1];
	$ent->configure(
		-disabledbackground => 'gray',
		-disabledforeground => 'black',
	) if $Tk::VERSION >= 804;
}

sub config_entry_focusin{
	my $ent = $_[1];
	$ent->configure(
		-validate => 'focusin',
		-validatecommand => sub{
			$ent->selectionRange(0,'end');
		}
	);
}

1;
