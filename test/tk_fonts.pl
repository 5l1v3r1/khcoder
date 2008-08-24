package FontTest;
use strict;
use Tk;
use Tk::Font;
use Tk::FontDialog;
use Jcode;
require Encode if $] > 5.008;

my $self;
$self->{mw} = MainWindow->new;
bless $self, 'FontTest';

my $mw = $self->{mw};

$self->{mw}->fontCreate('TKFN',
	-family => 'HiraginoKaku',
	-size   => 10
);
$self->{mw}->optionAdd('*font', "TKFN");

#$self->{mw}->Label(
#	-text => $self->gui_jchar('���ܸ�Υ�٥�'),
#	-font => "TKFN"
#)->pack();
#$self->{mw}->Button(
#	-text => $self->gui_jchar('Font�ѹ�'),
#	-font => "TKFN",
#	-command => sub {$self->font_change},
#)->pack;

$mw->Button(-text => "Button1", -command => sub { exit })->grid
  ($mw->Button(-text => "Button2", -command => sub { exit }),
   $mw->Button(-text => "Button3", -command => sub { exit }),
   $mw->Button(-text => "Button4", -command => sub { exit }),
   -sticky => "nsew");
 
$mw->Button(-text => "Button5", -command => sub { exit })->grid
  ("x",
   $mw->Button(-text => "Button7", -command => sub { exit }),
   $mw->Button(-text => "Button8", -command => sub { exit }),
   -sticky => "nsew");
 
#$mw->gridColumnconfigure(1, -weight => 1);
#$mw->gridRowconfigure(1, -weight => 1);



MainLoop;

sub font_change{
	my $self = shift;
	my $font = $self->{mw}->FontDialog(
		-title            => $self->gui_jchar('�ե���Ȥ�����'),
		-familylabel      => $self->gui_jchar('�ե���ȡ�'),
		-sizelabel        => $self->gui_jchar('��������'),
		-cancellabel      => $self->gui_jchar('����󥻥�'),
		-nicefontsbutton  => 0,
		-fixedfontsbutton => 0,
		-fontsizes        => [8,9,10,11,12,13,14,15,16,17,18,19,20],
		-sampletext       => $self->gui_jchar('KH Coder�Ϸ��̥ƥ�����ʬ�Ϥ�������뤿��Υġ���Ǥ���'),
		-initfont         => ,"TKFN"
	)->Show;
	return unless $font;

	$self->{mw}->fontDelete('TKFN');
	$self->{mw}->fontCreate('TKFN',
		-family => $font->configure(-family),
		-size   => $font->configure(-size),
	);
	$self->{mw}->optionAdd('*font', "TKFN");
	
	print $font->configure(-size)."\n";
}

sub gui_jchar{
	my $self = shift;
	my $str = shift;
	if ($] > 5.008){
		return Encode::decode('eucjp',$str);
	} else {
		return Jcode->new($str)->sjis;
	}
}
