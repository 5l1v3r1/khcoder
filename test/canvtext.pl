#! perl -w
# Title: �����Х��ƥ��������ܸ����ϥ���ץ�ץ����
# Author: ע�� �� (Tsutomu Hiroshima tsutomu@nucba.ac.jp)
# Date: 2000ǯ12��14��
#
# Canvas Widget �� Text ���֥������Ȥ�ʸ�����Τߡ����Խ�����ǥ�ץ����Ǥ���
# Canvas Widget �ϥǥե���Ȥ��Խ��Τ���ΥХ���ǥ��󥰤ϰ��ڹԤ��Ƥ��ޤ���Τǡ�
# ���Υץ�����������Ƥ���褦�ʥХ���ǥ��󥰤��Ѱդ���ɬ�פ�����ޤ���
#
# ������ Text ���֥������Ȥ��ä��ꡤ
# ������ Text ���֥������Ȥ��������ꡤ
# ��ư�����ꡤ�����Ѥ����ꤹ�뵡ǽ�Ϥ���ޤ���
#
# ����������Խ����֤��ư�����뤳�Ȥ�Ǥ��ޤ��󤬡�
# BackSpace �� Delete �� �����ʸ����õ���ꡤ
# ���åȡ����ԡ����ڡ����ȤϽ���ޤ���

use Tk;

### Canvas Widget �� ����ץåȥ᥽�åɤ�Ȥ��������
### �ǥե���Ȥ����ϥ��������
### ['PreeditArea', 'StatusArea'] �� ['PreeditNothing', 'StatusNothing']��
Tk::Kanji::UseIM('Tk::Canvas');

$mw = MainWindow->new;

### ���ξ��Ǽ���Ƥ֤Τ�
### Tk::Kanji::UseIM('Tk::Canvas');
### �ȡ�Ʊ�����̤��ġ�

#$mw->OpenIM('Tk::Canvas');

$cn = $mw->Canvas(-takefocus => 1, # �Խ����뤿��ˤϥե���������ɬ�ס�
		  -width => 300,
		  -height => 300,
		  -background => 'white')->pack;

### ���󥹥��� $cn ���������ܸ����Ϥ�Ȥ���������
### ���Τɤ��餫��Ƥ֡�

# $cn->OpenIM;
# $mw->OpenIM($cn);

$mw->title('�����Х��ƥ����Ȥؤ����ܸ�����');

### ��˥塼�κ�����
$mn = $mw->Menu;
$mw->configure(-menu => $mn);

$mn->add('cascade', -label => '�ե�����(F)', -underline => 5);
$mn->add('cascade', -label => '�Խ�(E)', -underline => 3);

$it1 = $mn->Menu;
$mn->entryconfigure('�ե�����(F)', -menu => $it1);
$it1->add('command',
	  -label => '����(P)',
	  -underline => 3,
	  -command => \&PrintPS);
$it1->add('separator');
$it1->add('command',
	  -label => '��λ(Q)',
	  -underline => 3,
	  -command => sub {exit});

$it2 = $mn->Menu;
$mn->entryconfigure('�Խ�(E)', -menu => $it2);

$it2->add('command', -label => '���å�(X)',
	  -underline => 4,
	  -command => [\&ClipCut, $cn]);
$it2->add('command', -label => '���ԡ�(C)',
	  -underline => 4,
	  -command => [\&ClipCopy, $cn]);
$it2->add('command', -label => '�ڡ�����(V)',
	  -underline => 5,
	  -command => [\&ClipPaste, $cn]);
### ��˥塼�κ����ν��ꡥ

### Text ���֥������Ȥκ�����
### �ܷ���ͤ���Ρ����� Perl/Tk�פ�
### ����ץ륹����ץȤ򻲹ͤˤ��ޤ�����
$cn->createText( 0, 30, -text => '���󥫡��ΰ���', -anchor => 'w');
@ap = (['e', 'magenta'], ['w', 'green'], ['s', 'blue'], ['n', 'red']);

foreach $p (@ap) {
  $cn->createText(150, 70, -text => "���󥫡�-$p->[0]", -anchor => $p->[0], 
		  -fill => $p->[1]);
}

$msg = '�褦������ Perl/Tk �������ء�����';

$cn->createText( 0, 120, -text => '���㥹�ƥ��ե���', -anchor => 'w');

@jf = ([150, 'left'], [200, 'center'], [250, 'right']);
foreach $p (@jf) {
  $cn->createText(150, $p->[0], -text => $msg, -width => 180, 
		  -justify => $p->[1]);	  
}
### Text ���֥������Ȥκ����ν��ꡥ

### �Խ��Τ���ΥХ���ǥ��󥰡�
### ���ܸ����ϤΤ�������̤ʤ��Ȥϰ��ڤ��Ƥ��ʤ���
### Canvas Widget �Ǥϡ�'Tk::' ����Ƭ����ɬ�ܡ�
$cn->Tk::bind('<Button-1>', [\&FocusText, Ev('x'), Ev('y')]);
$cn->Tk::bind('<ButtonRelease-1>', [\&EndDrag, Ev('x'), Ev('y')]);
$cn->Tk::bind('<Key>', [\&InsertChar, Ev('A')]);
$cn->Tk::bind('<Key-BackSpace>', [\&DeleteChar, -1]);
$cn->Tk::bind('<Key-Delete>', [\&DeleteChar, 0]);


MainLoop;

### �ե������˥塼 -> �������ޥ�ɤδؿ���
sub PrintPS {
  my $fname = $mw->getSaveFile(-initialfile => 'Untitled',
			       -defaultextension => '.ps');
  $cn->postscript(-file => $fname);
}

### �ܥ��󣱤򲡤������٥�ȤǸƤФ�롥
sub FocusText {
  my ($w, $x, $y) = @_;

  ### Canvas �˥ե���������ưŪ�ˤϰ�ư���Ƥ���ʤ��Τǡ�
  ### ���������ꡥ
  ### $w->focus �� Canvas ��� Text ���֥������ȴ֤�
  ### �ե��������ΰ�ư�˻Ȥ��Τ�
  ### 'Tk::' ����Ƭ����ɬ�ܡ�
  $w->Tk::focus;

  ### �ݥ���Ȥ˶ᤤ Text ���֥������Ȥ�����
  ### �Ťʤꤢ�äƤ����ͤ��ơ������˰�ư��
  ### ���Υ��֥������Ȥ˥ե����������֤��ơ�
  ### ���������ݥ���Ȥ����ꡥ
  my $tagOrId = $w->find('closest', $x, $y);
  $w->raise($tagOrId);
  $w->focus($tagOrId);
  $w->icursor($tagOrId, '@'."$x,$y");

  ### �������򤵤줿�ƥ����Ȥ�����С�������ˡ�
  ### ���߰��֤����򳫻ϰ��֤Ȥ��ơ�
  ### �ݥ��󥿤ΰ�ư���٥�Ȥ˥ƥ���������δؿ���Х����
  $w->selectClear;
  $w->selectFrom($tagOrId, '@'."$x,$y");
  $w->Tk::bind('<Motion>', [\&SelectText, Ev('x'), Ev('y')]);
}

### �ݥ��󥿤ΰ�ư�Υ��٥�ȤǸƤФ�롥
### ���������ΥХ���ɤϥܥ���򲡤��Ƥ���֤���ͭ����
### �ݥ��󥿤���ư�������֤Υƥ����ȤޤǤ����򤹤롥
sub SelectText {
  my ($w, $x, $y) = @_;
  my $focused = $w->focus;
  if ($focused) {
    $w->selectTo($focused,  '@'."$x,$y");
  }
}

### �ܥ��󣱤�Υ�������٥�ȤǸƤФ�롥
### �ݥ��󥿤ΰ�ư�˥Х���ɤ��Ƥ����ؿ��򥢥�Х���ɤ��롥
sub EndDrag {
  my $w = shift;
  $w->Tk::bind('<Motion>', '');
}

### ʸ���������Ⱥ���δؿ���
sub InsertChar {
  my ($w, $c) = @_;
  return unless $c;
  my $focused = $w->focus;
  if ($focused) {
    eval { $w->dchars($focused, 'sel.first', 'sel.last') };
    my $index = $w->index($focused, 'insert');
    $w->insert($focused, $index, $c);
  }
}

sub DeleteChar {
  my ($w, $c) = @_;
  my $focused = $w->focus;
  if ($focused) {
    eval { $w->dchars($focused, 'sel.first', 'sel.last') };
    if ($@) {
      my $index = $w->index($focused, 'insert');
      $w->dchars($focused, $index + $c);
    }
  }
}

### �Խ���˥塼 -> ���åȡ����ԡ����ڡ����ȥ��ޥ�ɤδؿ���
### �ܷ���ͤ���Ρ����� Perl/Tk�פ�
### ����ץ륹����ץȤ򻲹ͤˤ��ޤ�����
sub ClipCut {
  my $w = shift;
  ClipCopy($w);
  my $focused = $w->focus;
  if ($focused) {
    eval { $w->dchars($focused, 'sel.first', 'sel.last') };
  }
}

sub ClipCopy {
  my $w = shift;
  my $owner = $w->SelectionOwner;
  if ($owner && $owner eq $w) {
    my $selected = eval {$w->SelectionGet};
    if ($selected) {
      $w->clipboardClear;
      $w->clipboardAppend($selected);
    }
  }
}

sub ClipPaste {
  my $w = shift;
  my $owner = $w->SelectionOwner;
  my $focused = $w->focus;
  if ($focused) {
    my $index = $w->index($focused, 'insert');
    if ($owner && $owner eq $w) {
      eval { $w->dchars($focused, 'sel.first', 'sel.last') };
    }
    $w->insert($focused, $index,
	       $w->SelectionGet(-selection => 'CLIPBOARD'));
  }
}
