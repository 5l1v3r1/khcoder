# �Ǿ��¡ʤ˶ᤤ�����˥ץ饰������

package sample4_minimum;

sub plugin_config{
	return {
		name     => '�Ǿ��¤ι���',
		menu_grp => '����ץ�',         # ���ιԤϡ�����ϡ˾�ά��
	};
}

sub exec{
	print "short sample\n";             # ������ɬ�פʽ������Ƥ򵭽�
}

1;
