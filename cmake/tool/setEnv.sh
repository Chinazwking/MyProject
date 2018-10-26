#!/bin/bash

#
# ��黷�������Ƿ����
#
function checkEnvExist()
{
    # ʹ��������ʽ�ڻ�������֮�����������Ƿ���ڲ���������
    # eval��Ա��ʽ��������ɨ��, �������ΪSRC, ���һ��ɨ����Ϊ[ -z "$SRC" ]
    # �ڶ���ִ��[ -z "$SRC" ], ����-z�����ַ��������Ƿ�Ϊ0, ��[]��Ϊtest���ʽ��
    # ����0��1, ����ַ�������Ϊ0����ʽΪ��, ���null, �����������������ֵ
    if set | grep -E "^$1=">/dev/null
    then eval [ -z "\$$1" ] && echo null || eval echo \$$1
    else echo unset
    fi
}
#
# ���ñ�����Ҫ�Ļ�������
#
function setEnvs()
{
    #
    # cmake ��������
    #
    export CMAKE_PLATFORM_NAME      # ƽ̨���� RedHat, Windows
    export CMAKE_PLATFORM_VERSION   # ƽ̨�汾 5, 10
    export CMAKE_BUILD_VERSION      # cpu�ܹ� x86, x64
    export CMAKE_CXX_COMPILER       # C++������·��
    export CMAKE_C_COMPILER         # C������·��

    #
    # �������·��
    #
    export MYPLATFORM=${CMAKE_PLATFORM_NAME}_${CMAKE_PLATFORM_VERSION}_${CMAKE_BUILD_VERSION}
    export MYSRC=$MYPROJECT/src
    export MYDEPS=$MYPROJECT/deps
    export MYCMAKE=$MYPROJECT/cmake
    export MYTARGET=$MYPROJECT/target/$MYPLATFORM/libs
    export MYBUILD=$MYPROJECT/target/$MYPLATFORM/build
    export MYPROJECT=$MYPROJECT

    #
    # ��toolĿ¼���뻷������
    #
    export PATH=$PATH:$MYPROJECT/cmake/tool

    #
    # Ϊ���нű���ӿ�ִ��Ȩ��
    #
    chmod -R +x $MYPROJECT/cmake/tool/*.sh

    #
    # ����������ý��
    #
    echo "****************************************************************"
    echo "MYSRC is                   $MYSRC"
    echo "MYDEPS is                  $MYDEPS"
    echo "MYCMAKE is                 $MYCMAKE"
    echo "MYBUILD is                 $MYBUILD"
    echo "MYTARGET is                $MYTARGET"
    echo "CMAKE_PLATFORM_NAME is     $CMAKE_PLATFORM_NAME"
    echo "CMAKE_PLATFORM_VERSION is  $CMAKE_PLATFORM_VERSION"
    echo "CMAKE_BUILD_VERSION is     $CMAKE_BUILD_VERSION"
    echo "****************************************************************"

    echo "Go to \$MYSRC"

    alias makec='makec.sh'

    cd $MYSRC
}
