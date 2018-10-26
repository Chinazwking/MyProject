#!/bin/bash

#
# �˽ű���Ŀ������Ϊ��cmake���������ڴ���·������������ʱ�ļ������޷�ɾ��
# ���ʹ�ýű������й�����ʱ���
#

#
# ��������
#

# ����Դ����·��
CMAKE_BUILD_SRC=`pwd`
# �������� Ĭ��Debug
CMAKE_BUILD_TYPE=Debug
# �������� [compile, clean, cleanall, help]
CMAKE_BUILD_ARGU=compile
# �������
CMAKE_BUILD_VERBOSE=0
# ����ʹ�ú�����
CMAKE_BUILD_CPU_COUNT=

#
# ���������Ϣ
#

function usage ()
{
    echo ""
    echo "makec [release] clean: ����Ѿ����ɵı�������"
    echo "makec: �޲������debug��"
    echo ""
    echo "makec [release] cleanall: ������������Լ������ļ�"
    echo "makec: �޲������debug��"
    echo ""
    echo "makec [release/debug]: ����[release/debug]���ļ�"
    echo "makec: �޲�������debug��"
    echo ""
    echo "makec [relese/debug] package: ���� [release/debug]���"
    echo ""
    echo "makec help: ��ʾ����"
    echo ""
}

#
# ���������ʵ�� (CMAKE_BUILD_ARGU=clean)
#
function clean()
{
    echo "cleaning build in $CMAKE_BUILD_DIR ..."

    if [ ! -d $CMAKE_BUILD_DIR ]
    then
        mkdir -p $CMAKE_BUILD_DIR
    fi

    if [ -d $CMAKE_BUILD_DIR ]
    then
        cd $CMAKE_BUILD_DIR
        CURDIR=`pwd`
        echo "Start cleaning in $CURDIR ..."
        if [ -f Makefile ]
        then
            make clean
        fi
        cd -
    fi

    echo "clean builddir end ..."
}

#
# ȫ���������ʵ�� (CMAKE_BUILD_ARGU=cleanall)
#
function cleanall()
{
    echo "cleaning all build in $CMAKE_BUILD_DIR ..."

    if [ ! -d $CMAKE_BUILD_DIR ]
    then
        mkdir -p $CMAKE_BUILD_DIR
    fi

    if [ -d $CMAKE_BUILD_DR ]
    then
        cd $CMAKE_BUILD_DIR
        CURDIR=`pwd`
        echo "Start cleaning all in $CURDIR ..."
        if [ -f Makefile ]
        then
            make clean
        fi
        cd -
        rm -rf $CMAKE_BUILD_DIR
    fi

    echo "cleaning all build end ..."
}

#
# ���� (CMAKE_BUILD_ARGU=generate)
#
function generate()
{
    if [ ! -d $CMAKE_BUILD_DIR ]
    then
        echo "Create build directory ..."
        mkdir -p $CMAKE_BUILD_DIR
    fi

    cd $CMAKE_BUILD_DIR

    CURDIR=`pwd`

    if [ ! -f Makefile ]
    then
        echo "Start generating in $CURDIR ..."
        echo "================================================================"
        echo "CMAKE_PLATFORM_NAME is        $CMAKE_PLATFORM_NAME"
        echo "CMAKE_PLATFORM_VERSION is     $CMAKE_PLATFORM_VERSION"
        echo "CMAKE_CXX_COMPILER is         $CMAKE_CXX_COMPILER"
        echo "CMAKE_C_COMPILER is           $CMAKE_C_COMPILER"
        echo "CMAKE_BUILD_VERSION is        $CMAKE_BUILD_VERSION"
        echo "CMAKE_BUILD_TYPE is           $CMAKE_BUILD_TYPE"
        echo "================================================================"
        cmake -DCMAKE_PLATFORM_NAME=${CMAKE_PLATFORM_NAME}          \
              -DCMAKE_PLATFORM_VERSION=${CMAKE_PLATFORM_VERSION}    \
              -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}            \
              -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}                \
              -DCMAKE_BUILD_VERSION=${CMAKE_BUILD_VERSION}          \
              -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}                \
              -DMYCMAKE=${MYCMAKE}                                  \
              -DAUTO_RUN=1                                          \
              $CMAKE_BUILD_SRC
    fi
}

#
# ���� (CMAKE_BUILD_ARGU=compile)
#
function compile()
{
    generate
    echo "Start compiling in $PWD ..."
    if [ $CMAKE_BUILD_VERBOSE == "1" ]
    then
        make VERBOSE=1 $CMAKE_BUILD_CPU_COUNT
    else
        make $CMAKE_BUILD_CPU_COUNT
    fi
}

#
# ��� (CMAKE_BUILD_ARGU=package)
#
function package()
{
    generate
    echo "Start compiling and packaging in $PWD ..."
    if [ $CMAKE_BUILD_VERBOSE == "1" ]
    then
        make VERBOSE=1 package $CMAKE_BUILD_CPU_COUNT
    else
        make package $CMAKE_BUILD_CPU_COUNT
    fi
}

#
# ���칹������
#
function check()
{
    case $1 in
        [Rr]elease)
            CMAKE_BUILD_TYPE=Release
            ;;
        [Vv]erbose)
            CMAKE_BUILD_VERBOSE=1
            ;;
        -j*)
            CMAKE_BUILD_CPU_COUNT=$1
            ;;
        [Gg]en*)
            CMAKE_BUILD_ARGU=generate
            ;;
        [Pp]ackage)
            CMAKE_BUILD_ARGU=package
            ;;
        [Cc]lean)
            CMAKE_BUILD_ARGU=clean
            ;;
        [Cc]leanall)
            CMAKE_BUILD_ARGU=cleanall
            ;;
        [Hh]elp)
            CMAKE_BUILD_ARGU=help
            ;;
    esac
}

check $1
check $2
check $3
check $4

# �����ļ�·�� ${#*}��һ������ı����÷�
CMAKE_BUILD_DIR=${MYBUILD}/${CMAKE_BUILD_TYPE}/${CMAKE_BUILD_SRC#*MyProject/}/Build

# ʵ�ʹ�������
case $CMAKE_BUILD_ARGU in
    compile)
        compile
        exit 0
        ;;
    package)
        package
        exit 0
        ;;
    generate)
        generate
        exit 0
        ;;
    clean)
        clean
        exit 0
        ;;
    cleanall)
        cleanall
        exit 0
        ;;
    help)
        usage
        exit 0
        ;;
esac
