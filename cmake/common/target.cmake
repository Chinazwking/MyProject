MESSAGE(STATUS "\n\n**include:target.cmake\n")

####################################################################################################
MESSAGE(STATUS "\n**deps-----------------------------------------------------------------------------")


# ����Ƿ����configĿ¼,����Ŀ¼�ļ�������lib�����ڵ�Ŀ¼��
# �����п����Ķ������������ļ����Է�����configĿ¼
SET(DEFAULT_CONFIG_PATH  ${CMAKE_CURRENT_SOURCE_DIR}/config)
MESSAGE(STATUS "SET DEFAULT_CONFIG_PATH = ${DEFAULT_CONFIG_PATH}")
IF(EXISTS ${DEFAULT_CONFIG_PATH})
    FILE(INSTALL ${DEFAULT_CONFIG_PATH}/ DESTINATION ${LIBS_PATH} PATTERN ".svn" EXCLUDE)
    install_dir(${DEFAULT_CONFIG_PATH}/ "")
    MESSAGE(STATUS "install_dir(${DEFAULT_CONFIG_PATH})")
ENDIF()


# ����Ƿ����serviceĿ¼,����Ŀ¼�ļ�����������lib�����ڵ�Ŀ¼��
# �����п����Ķ������ʷ����ļ����Է����ڸ�ģ�����ڵ�serviceĿ¼
SET(DEFAULT_SERVICE_PATH  ${CMAKE_CURRENT_SOURCE_DIR}/service)
MESSAGE(STATUS "SET DEFAULT_SERVICE_PATH = ${DEFAULT_SERVICE_PATH}")
IF(EXISTS ${DEFAULT_SERVICE_PATH})
    IF(EXISTS ${DEFAULT_SERVICE_PATH}/${ABPLATFORM})
        FILE(INSTALL ${DEFAULT_SERVICE_PATH}/${ABPLATFORM}/ DESTINATION ${LIBS_PATH})
        install_dir(${DEFAULT_SERVICE_PATH}/${ABPLATFORM}/ "")
    ENDIF()
    MESSAGE(STATUS "install_dir(DEFAULT_SERVICE_PATH)")
ENDIF()


# ���Ŀ¼���Ƿ��� images Ŀ¼
SET(DEFAULT_IMAGES_PATH ${CMAKE_CURRENT_SOURCE_DIR}/images)
MESSAGE(STATUS "SET DEFAULT_IMAGES_PATH = ${DEFAULT_IMAGES_PATH}")
IF(EXISTS ${DEFAULT_IMAGES_PATH})
    FILE(INSTALL ${DEFAULT_IMAGES_PATH} DESTINATION ${LIBS_PATH})
    install_dir(${DEFAULT_IMAGES_PATH} "")
    MESSAGE(STATUS "install_dir(${DEFAULT_IMAGES_PATH})")
ENDIF()


# ��������������ѡ��
# ע:��������Ӧ��NEED_XXX�£��������������������Ͳ���
# �����CMakeLists.txt����������NEED_XXXѡ�


# ���� boost �������
IF(${NEED_BOOST})
    FIND_PACKAGE(boost REQUIRED)
ENDIF()

# ���� googletest �������
IF(${NEED_GTEST})
    FIND_PACKAGE(gtest REQUIRED)
ENDIF()


#
# ���� �ڲ��������
#
#Ĭ�ϰ�������Ŀ¼
INCLUDE_DIRECTORIES(${MKCPP};)

# ���� NEED_BASECOMMON
IF(${NEED_BASECOMMON})
    MESSAGE(STATUS "basecommon is used")
    ADD_DEFINITIONS(-D__USING_BASECORE__)
    seek_base_library_no_install(${LIBS_PATH} basecommon)
    INCLUDE_DIRECTORIES(${MKCPP}/basecommon/include;
                        ${MKCPP}/basecommon/src;)
    SET(LINK_BASECORE_LIBS basecommon)
ENDIF()

# ���� APPCORE
IF(${NEED_APPCORE})
    FIND_PACKAGE(basecore REQUIRED)
    FIND_PACKAGE(appcore REQUIRED)
    SET(CUSTOM_IDL_PATH ${CUSTOM_IDL_PATH};$ENV{APPCORE}/public)
    INCLUDE_DIRECTORIES($ENV{APPCORE};$ENV{APPCORE}/public;$ENV{APPCORE}/include)
ENDIF()

# ���� DATACAHNNEL
IF (${NEED_DATACHANNEL})
    SET(CUSTOM_IDL_PATH ${CUSTOM_IDL_PATH};$ENV{DATACHANNEL}/public)
    INCLUDE_DIRECTORIES($ENV{DATACHANNEL};$ENV{DATACHANNEL}/public)
ENDIF()



# CMAKE_CURRENT_SOURCE_DIR
IF(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/../public)
    GET_FILENAME_COMPONENT(PARENT_PATH ${CMAKE_CURRENT_SOURCE_DIR} PATH)
    # �����Զ���� IDL ·��
    SET(CUSTOM_IDL_PATH ${PARENT_PATH}/public
                        ${CUSTOM_IDL_PATH})
ENDIF()

IF(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/../private)
    # �����Զ���� IDL ·��
    GET_FILENAME_COMPONENT(PARENT_PATH ${CMAKE_CURRENT_SOURCE_DIR} PATH)
    SET(CUSTOM_IDL_PATH ${PARENT_PATH}/private
                        ${CUSTOM_IDL_PATH})
ENDIF()




# ע�⣺ÿ������µ�NEED_XXX�������������Ҫ�����µ������⣬��Ҫ�����ı�������LINK_ALL_LIBS�����ڡ�
# �������е����ӿ�
SET(LINK_ALL_LIBS   ${LINK_SDL2_LIBS})

MESSAGE(STATUS "SET LINK_ALL_LIBS = ${LINK_ALL_LIBS}")


####################################################################################################
MESSAGE(STATUS "\n**compile_IDL-----------------------------------------------------------------------")

MESSAGE(STATUS "GET CUSTOM_IDL_PATH = ${CUSTOM_IDL_PATH}")

## ����Ƿ���IDL�ļ���Ҫ���� (֧��ָ�����IDL�ļ�Ŀ¼)
IF(DEFINED CUSTOM_IDL_PATH)
    # ע:Ϊ�ӿ����,public��Ŀ¼����������.h��.xpt�ļ����򲻻��ٴα���idl�ļ�.
    # ��Ҫ�ֶ����±���idl�ļ�������ִ��`make clean`,Ȼ��ִ�� `cmake xxx`

    # ����IDL�ļ�����·��
    list(APPEND DEPS_IDL_PATH    "-I$ENV{APPCORE}/public")
    list(APPEND DEFAULT_IDL_PATH   "$ENV{APPCORE}/public")

    # DEFAULT_IDL_PATH ��������IDL�ļ�Ŀ¼������ָ�����Ŀ¼
    IF(DEFINED CUSTOM_IDL_PATH)
        SET(DEFAULT_IDL_PATH ${DEFAULT_IDL_PATH};${CUSTOM_IDL_PATH})
        MESSAGE(STATUS "SET DEFAULT_IDL_PATH = ${DEFAULT_IDL_PATH}")
    ENDIF()

    # ����ЩĿ¼��ӵ�IDL�ļ��ı���ѡ���У������ж��Ƿ������·��
    FOREACH(each_deps_idl_path ${DEFAULT_IDL_PATH})
        list(APPEND DEPS_IDL_PATH "-I${each_deps_idl_path}")
    ENDFOREACH()

    # ȥ���ظ�����ѡ��
    list(REMOVE_DUPLICATES DEPS_IDL_PATH)
    list(REMOVE_DUPLICATES DEFAULT_IDL_PATH)
    MESSAGE(STATUS "GET DEPS_IDL_PATH = ${DEPS_IDL_PATH}")
    MESSAGE(STATUS "GET DEFAULT_IDL_PATH = ${DEFAULT_IDL_PATH}")

    # ����IDL ��ִ���ļ�·��
    IF(WIN32)
        SET(XPIDL_NAME xpidl.exe)
        MESSAGE(STATUS "SET XPIDL_NAME = ${XPIDL_NAME}")
    ELSE()
        SET(XPIDL_NAME xpidl)
        MESSAGE(STATUS "SET XPIDL_NAME = ${XPIDL_NAME}")
    ENDIF()

    #����idl�ļ�
    IF((EXISTS ${ABDEPS}/xpidl/bin/${ABPLATFORM}/${CMAKE_BUILD_TYPE}/${XPIDL_NAME}))
        SET(XPIDL ${ABDEPS}/xpidl/bin/${ABPLATFORM}/${CMAKE_BUILD_TYPE}/${XPIDL_NAME})
        MESSAGE(STATUS "SET XPIDL = ${XPIDL}")

        IF(NOT WIN32)
            EXECUTE_PROCESS(COMMAND chmod +x ${XPIDL})
        ENDIF()
    ELSE()
        MESSAGE(WARNING "(LINE:${CMAKE_CURRENT_LIST_LINE}) Not found executable ${XPIDL_NAME} and ${XPTLINK_NAME}")
    ENDIF()

    MESSAGE(STATUS "Compile IDL files...")

    FOREACH(each_idl_path ${DEFAULT_IDL_PATH})
        MESSAGE(STATUS "GET each_idl_path = ${each_idl_path}")
        # ���RELATIVE flag ָ�������᷵��RELATIVE flag�����·��
        # FILE(GLOB ...)���ص��Ǿ���·��
        FILE(GLOB IDL_FILES "${each_idl_path}/*.idl")
        FILE(GLOB IDL_H_FILES "${each_idl_path}/*.h")
        IF(NOT "${IDL_FILES}" STREQUAL "")
            FOREACH(_in_file ${IDL_FILES})
                # ��ȡ�ļ�����·��
                GET_FILENAME_COMPONENT(_out_file ${_in_file} NAME_WE)
                GET_FILENAME_COMPONENT(_in_PATH ${_in_file} PATH)
                GET_FILENAME_COMPONENT(_out_NAME ${_in_PATH} NAME)
                SET(_out_PATH ${PROJECT_BINARY_DIR}/${_out_NAME})
                file(MAKE_DIRECTORY ${_out_PATH})
                INCLUDE_DIRECTORIES(${_out_PATH})
                INCLUDE_DIRECTORIES(${PROJECT_BINARY_DIR})

                # ����ÿ��idl�ļ��Ƿ����
                #MESSAGE(STATUS "COMMAND ${XPIDL} ${DEPS_IDL_PATH} ${_in_file} ...")
                ADD_CUSTOM_COMMAND(OUTPUT ${_out_PATH}/${_out_file}.h
                                COMMAND ${XPIDL}
                                ARGS ${DEPS_IDL_PATH} -m header -w -v -e ${_out_PATH}/${_out_file}.h  ${_in_file}
                                WORKING_DIRECTORY ${_in_PATH}
                                COMMENT ""
                                )

                LIST(APPEND IDL_HEADER_FILES ${_out_PATH}/${_out_file}.h)
                LIST(APPEND IDL_CLEAN_FILES ${_out_PATH}/${_out_file}.h)
            ENDFOREACH(_in_file)

            SET_SOURCE_FILES_PROPERTIES(${IDL_HEADER_FILES} PROPERTIES GENERATED TRUE)
            SET(${IDL_HEADER_FILES} ${IDL_HEADER_FILES})
        ENDIF()
    ENDFOREACH(each_idl_path)

    # success
    MESSAGE(STATUS "Compile IDL files SUCCESS...")

    # �������
    UNSET(DEPS_IDL_PATH)
    UNSET(DEFAULT_IDL_PATH)
ENDIF()




####################################################################################################
MESSAGE(STATUS "\n**info-----------------------------------------------------------------------------")

# �����Ƿ��Զ�ִ�����ɵĿ�ִ���ļ�
IF(AUTO_RUN)
   #MESSAGE(STATUS "enable auto_run...")
ENDIF()
MESSAGE(STATUS "GET AUTO_RUN = ${AUTO_RUN}")

# ���һЩbuild ��Ϣ(��ѡ )
MESSAGE(STATUS "GET CMAKE_SYSTEM_NAME = ${CMAKE_SYSTEM_NAME}")
MESSAGE(STATUS "GET CMAKE_SYSTEM = ${CMAKE_SYSTEM}")
MESSAGE(STATUS "GET CMAKE_SYSTEM_VERSION = ${CMAKE_SYSTEM_VERSION}")
MESSAGE(STATUS "GET CMAKE_SYSTEM_PROCESSOR = ${CMAKE_SYSTEM_PROCESSOR}")
MESSAGE(STATUS "GET PROJECT_NAME = ${PROJECT_NAME}")
MESSAGE(STATUS "GET CMAKE_GENERATOR = ${CMAKE_GENERATOR}")
MESSAGE(STATUS "GET CMAKE_BUILD_TYPE = ${CMAKE_BUILD_TYPE}")
MESSAGE(STATUS "GET TARGET_TYPE = ${TARGET_TYPE}")
MESSAGE(STATUS "GET CMAKE_BUILD_VERSION = ${CMAKE_BUILD_VERSION}")
MESSAGE(STATUS "GET PROJECT_BINARY_DIR = ${PROJECT_BINARY_DIR}")
MESSAGE(STATUS "...")



####################################################################################################
MESSAGE(STATUS "\n**get_sourcefiles------------------------------------------------------------------")


# ��ȡ��ǰĿ¼������Ŀ¼�µ�����Դ�ļ�
SET(SRC "")
FOREACH(subdir ${SOURCE_DIRS})
    IF(EXISTS ${subdir}/res)
        IF(NOT DEFINED RES_TARGET_NAME)
            SET(RES_TARGET_NAME "-")
        ENDIF()
        add_res_files_target(${subdir}/res ${LIBS_PATH} each_res_clean_files ${RES_TARGET_NAME})
    ENDIF()

    AUX_SOURCE_DIRECTORY(${subdir} subdir_src)

    MESSAGE(STATUS "GET subdir_src = ${subdir_src}")
    SET(SRC ${SRC} ${subdir_src})
    SET(RES_CLEAN_FILES ${RES_CLEAN_FILES} ${each_res_clean_files})
    SET(subdir_src "")
    SET(each_res_clean_files "")
ENDFOREACH(subdir ${DIRS})

SET(SOURCESRCS ${SRC})
#MESSAGE(STATUS "SET SOURCESRCS = ${SOURCESRCS}")



# ��ȡ����Դ�ļ�,��ͳһ������Ѿ���·����ʾ���ļ���,�Ա�����ļ�����
SET(ALLSRCS ${SOURCESRCS} ${INCLUDE_SOURCE_FILES})
SET(ALL_SOURCES "")

FOREACH(_allsrc ${ALLSRCS})
    get_filename_component(_allsrc_path ${_allsrc} PATH)
    get_filename_component(_allsrc_name ${_allsrc} NAME)
    # _allsrc_pathΪ�ձ�ʾ��ǰ·��
    IF("${_allsrc_path}" STREQUAL "")
        SET(ALL_SOURCES ${ALL_SOURCES} ${CMAKE_CURRENT_SOURCE_DIR}/${_allsrc})
    ELSEIF("${_allsrc_path}" STREQUAL ".")
        SET(ALL_SOURCES ${ALL_SOURCES} ${CMAKE_CURRENT_SOURCE_DIR}/${_allsrc_name})
    ELSEIF(IS_ABSOLUTE ${_allsrc_path})
        SET(ALL_SOURCES ${ALL_SOURCES} ${_allsrc})
    ELSE()
        SET(ALL_SOURCES ${ALL_SOURCES} ${CMAKE_CURRENT_SOURCE_DIR}/${_allsrc})
    ENDIF()
ENDFOREACH()

#MESSAGE(STATUS "SET ALL_SOURCES = ${ALL_SOURCES}")




#���˲���Ҫ������ļ�
IF("${EXCLUDE_SOURCE_FILES}" STREQUAL "")
    SET(OUTPUTS ${ALL_SOURCES}
                ${THRIFT_GEN_CPP_HDRS}
                ${THRIFT_GEN_CPP_SRCS}
                ${IDL_HEADER_FILES})
ELSE()
    SET(ALL_EXCLUDE_SOURCE_FILES "")
    FOREACH(_exclude_source_file ${EXCLUDE_SOURCE_FILES})
        get_filename_component(_exclude_source_file_path ${_exclude_source_file} PATH)
        get_filename_component(_exclude_source_file_name ${_exclude_source_file} NAME)
        # Ϊ�ձ�ʾ��ǰ·��
        IF("${_exclude_source_file_path}" STREQUAL "")
            SET(ALL_EXCLUDE_SOURCE_FILES ${ALL_EXCLUDE_SOURCE_FILES} ${CMAKE_CURRENT_SOURCE_DIR}/${_exclude_source_file})
        ELSEIF("${_exclude_source_file_path}" STREQUAL ".")
            set(ALL_EXCLUDE_SOURCE_FILES ${ALL_EXCLUDE_SOURCE_FILES} ${CMAKE_CURRENT_SOURCE_DIR}/${_exclude_source_file_name})
        ELSEIF(IS_ABSOLUTE ${_exclude_source_file_path})
            SET(ALL_EXCLUDE_SOURCE_FILES ${ALL_EXCLUDE_SOURCE_FILES} ${_exclude_source_file})
        ELSE()
            SET(ALL_EXCLUDE_SOURCE_FILES ${ALL_EXCLUDE_SOURCE_FILES} ${CMAKE_CURRENT_SOURCE_DIR}/${_exclude_source_file})
        ENDIF()
    ENDFOREACH()
    # ���˲���Ҫ������ļ�����Ҫ������ļ��ŵ�����OUTPUTS
    FILTER_OUT("${ALL_EXCLUDE_SOURCE_FILES}" "${ALL_SOURCES}" OUTPUTS)
    SET(OUTPUTS ${OUTPUTS}
                ${THRIFT_GEN_CPP_HDRS}
                ${THRIFT_GEN_CPP_SRCS}
                ${IDL_HEADER_FILES})
ENDIF()

MESSAGE(STATUS "SET ALL_EXCLUDE_SOURCE_FILES = ${ALL_EXCLUDE_SOURCE_FILES}")
MESSAGE(STATUS "SET OUTPUTS = ${OUTPUTS}")






####################################################################################################
MESSAGE(STATUS "\n**link_target----------------------------------------------------------------------")


#  ����
# �����������ɿ�Ϳ�ִ���ļ���·�����ڴ�ͳһ�������·����
# ���ò�ͬ��CMAKE_GENERATOR������Ŀ��·��(���MSVC���Զ�����Debug��ReleaseĿ¼)

# First for the generic no-config case (e.g. with mingw)
SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${LIBS_PATH})
SET(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${LIBS_PATH})
SET(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${LIBS_PATH})
MESSAGE(STATUS "SET CMAKE_RUNTIME_OUTPUT_DIRECTORY = ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
MESSAGE(STATUS "SET CMAKE_LIBRARY_OUTPUT_DIRECTORY = ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
MESSAGE(STATUS "SET CMAKE_ARCHIVE_OUTPUT_DIRECTORY = ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}")


# Second, for multi-config builds (e.g. msvc)
FOREACH(OUTPUTCONFIG ${CMAKE_CONFIGURATION_TYPES})
    MESSAGE(STATUS "GET OUTPUTCONFIG = ${OUTPUTCONFIG}")
    string(TOUPPER ${OUTPUTCONFIG} OUTPUTCONFIG)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${LIBS_PATH})
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${LIBS_PATH})
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${LIBS_PATH})
ENDFOREACH(OUTPUTCONFIG CMAKE_CONFIGURATION_TYPES)


# link����
MESSAGE(STATUS "GET TARGET_TYPE = ${TARGET_TYPE}")
IF("${TARGET_TYPE}" STREQUAL "RUNTIME")
    #�����RUNTIME�������ɿ�ִ���ļ�
    # win32 windows������Ҫ����WIN32ѡ��
    IF(WIN32)
        IF("${SUBSYSTEM}" STREQUAL "WINDOWS")
            SET(EXPECT_LINK_FLAG WIN32)
            MESSAGE(STATUS "SET EXPECT_LINK_FLAG = ${EXPECT_LINK_FLAG}")
        ENDIF()
        IF(NOT MSVC_2015)
            SET(CUSTOM_LDFLAGS "${CUSTOM_LDFLAGS} /MANIFESTUAC:\"level='requireAdministrator' uiAccess='false'\"")
            MESSAGE(STATUS "SET CUSTOM_LDFLAGS = ${CUSTOM_LDFLAGS}")
        ENDIF()
    ENDIF()

    #�����RUNTIME,�����ɿ�ִ���ļ�
    LINK_DIRECTORIES(${LIBS_PATH})
    ADD_EXECUTABLE(${TARGET_NAME} ${EXPECT_LINK_FLAG} ${OUTPUTS})
    TARGET_LINK_LIBRARIES(${TARGET_NAME} ${LINK_ALL_LIBS})
    MESSAGE(STATUS "TARGET_LINK_LIBRARIES(${TARGET_NAME} ${LINK_ALL_LIBS})")

    #RUNTIME
    install_target(RUNTIME ${TARGET_NAME} .)

    #debuginfo
    MESSAGE(STATUS "GET NEED_DEBUGINFO = ${NEED_DEBUGINFO}")
    IF(NEED_DEBUGINFO)
        SET(TARGET_FULL_NAME ${TARGET_NAME})
        ADD_CUSTOM_COMMAND(TARGET ${TARGET_NAME}
                           COMMAND objcopy --only-keep-debug ${TARGET_FULL_NAME} ${TARGET_FULL_NAME}.debug
                           COMMAND objcopy --strip-debug ${TARGET_FULL_NAME}
                           COMMAND objcopy --add-gnu-debuglink=${TARGET_FULL_NAME}.debug ${TARGET_FULL_NAME}
                           WORKING_DIRECTORY ${LIBS_PATH})
        LIST(APPEND DEBUGINFO_CLEAN_FILES ${LIBS_PATH}/${TARGET_FULL_NAME}.debug)
        install_files(debuginfo ${LIBS_PATH}/${TARGET_FULL_NAME}.debug)
    ENDIF()


    #�ж��Ƿ��Զ�ִ�У���AUTO_RUN�������͹ر�
    IF(WIN32)
        SET(RUN_NAME ${TARGET_NAME}.exe)
        IF(AUTO_RUN)
            ADD_CUSTOM_TARGET(RUN_${TARGET_NAME} ALL
                                COMMAND start /WAIT ${RUN_NAME}
                                DEPENDS ${TARGET_NAME}
                                WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
                                COMMENT "running ${RUN_NAME} ... "
                    )
        ELSE()
            ADD_CUSTOM_TARGET(RUN_${TARGET_NAME}
                                COMMAND start /WAIT ${RUN_NAME}
                                DEPENDS ${TARGET_NAME}
                                WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
                                COMMENT "running ${RUN_NAME} ... "
                    )
        ENDIF()
    ELSE()
        SET(RUN_NAME ${TARGET_NAME})
        IF(AUTO_RUN)
            ADD_CUSTOM_TARGET(RUN_${TARGET_NAME} ALL
                                COMMAND ${RUN_NAME}
                                DEPENDS ${TARGET_NAME}
                                WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
                                COMMENT "running ${RUN_NAME} ... "
                    )
        ELSE()
            ADD_CUSTOM_TARGET(RUN_${TARGET_NAME}
                                COMMAND ${RUN_NAME}
                                DEPENDS ${TARGET_NAME}
                                WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
                                COMMENT "running ${RUN_NAME} ... "
                    )
        ENDIF()
    ENDIF()

    #���븲����
    MESSAGE(STATUS "GET ENABLE_GCOV = ${ENABLE_GCOV}")
    IF (ENABLE_GCOV AND NOT WIN32 AND NOT APPLE)
        INCLUDE(EnableCoverageReport)
        SET(CURRENT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
        MESSAGE(STATUS "SET CURRENT_PATH = ${CURRENT_PATH}")

        GET_FILENAME_COMPONENT(SRC_NAME ${CURRENT_PATH} NAME)

        WHILE(NOT ${SRC_NAME} STREQUAL "test")
            GET_FILENAME_COMPONENT(PARENT_PATH ${CURRENT_PATH} PATH)
            GET_FILENAME_COMPONENT(SRC_NAME ${PARENT_PATH} NAME)
            SET(CURRENT_PATH ${PARENT_PATH})
        ENDWHILE()

        GET_FILENAME_COMPONENT(COVERAGE_SOURCE_DIR ${CURRENT_PATH} PATH)
        GET_FILENAME_COMPONENT(COVERAGE_SOURCE_NAME ${COVERAGE_SOURCE_DIR} NAME)
        GET_FILENAME_COMPONENT(PARENT_PATH ${CMAKE_CURRENT_SOURCE_DIR} PATH)

        ENABLE_COVERAGE_REPORT(TARGETS ${TARGET_NAME} FILTER "*deps*;/usr/include/*;/usr/lib/*")
    ENDIF()

    #���ܷ���
    MESSAGE(STATUS "GET ENABLE_PROFILE = ${ENABLE_PROFILE}")
    IF(ENABLE_PROFILE AND WIN32)
        SET_TARGET_PROPERTIES(${TARGET_NAME} PROPERTIES LINK_FLAGS /PROFILE)
    ENDIF()

ELSEIF("${TARGET_TYPE}" STREQUAL "LIBRARY")
    # ���ӳ�һ����̬��
    LINK_DIRECTORIES(${LIBS_PATH})
    ADD_LIBRARY(${TARGET_NAME} SHARED ${OUTPUTS})
    TARGET_LINK_LIBRARIES(${TARGET_NAME} ${LINK_ALL_LIBS})
    MESSAGE(STATUS "TARGET_LINK_LIBRARIES(${TARGET_NAME} ${LINK_ALL_LIBS})")

    #LIBRARY
    IF(WIN32)
        # Windows�µĶ�̬�ⱻ��Ϊ��RUNTIME����
        install_target(RUNTIME ${TARGET_NAME} .)
        install_target(ARCHIVE ${TARGET_NAME} .)
    ELSE()
        install_target(LIBRARY ${TARGET_NAME} .)
    ENDIF()

    #debuginfo
    MESSAGE(STATUS "GET NEED_DEBUGINFO = ${NEED_DEBUGINFO}")
    IF(NEED_DEBUGINFO)
        SET(TARGET_FULL_NAME ${CMAKE_SHARED_LIBRARY_PREFIX}${TARGET_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX})
        ADD_CUSTOM_COMMAND(TARGET ${TARGET_NAME}
                           COMMAND objcopy --only-keep-debug ${TARGET_FULL_NAME} ${TARGET_FULL_NAME}.debug
                           COMMAND objcopy --strip-debug ${TARGET_FULL_NAME}
                           COMMAND objcopy --add-gnu-debuglink=${TARGET_FULL_NAME}.debug ${TARGET_FULL_NAME}
                           WORKING_DIRECTORY ${LIBS_PATH})
        LIST(APPEND DEBUGINFO_CLEAN_FILES ${LIBS_PATH}/${TARGET_FULL_NAME}.debug)
        install_files(debuginfo ${LIBS_PATH}/${TARGET_FULL_NAME}.debug)
    ENDIF()
ELSEIF("${TARGET_TYPE}" STREQUAL "ARCHIVE")
    # ���ӳ�һ����̬��
    LINK_DIRECTORIES(${LIBS_PATH})
    ADD_LIBRARY(${TARGET_NAME} STATIC ${OUTPUTS})
    TARGET_LINK_LIBRARIES(${TARGET_NAME} ${LINK_ALL_LIBS})
    MESSAGE(STATUS "TARGET_LINK_LIBRARIES(${TARGET_NAME} ${LINK_ALL_LIBS})")
    install_target(ARCHIVE ${TARGET_NAME} .)
ELSEIF("${TARGET_TYPE}" STREQUAL "COMPONENT")
    # ���ӳ�һ�������
    #��������Ŀ��Ϊ������ر������λ��Ϊ${LIBS_PATH}/components

    # First for the generic no-config case (e.g. with mingw)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${LIBS_PATH}/components)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${LIBS_PATH}/components)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${LIBS_PATH}/components)

    # Second, for multi-config builds (e.g. msvc)
    foreach(OUTPUTCONFIG ${CMAKE_CONFIGURATION_TYPES})
        string(TOUPPER ${OUTPUTCONFIG} OUTPUTCONFIG)
        set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${LIBS_PATH}/components)
        set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${LIBS_PATH}/components)
        set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${LIBS_PATH}/components)
    endforeach(OUTPUTCONFIG CMAKE_CONFIGURATION_TYPES)

    #�����COMPONENT�������ɶ�̬��
    LINK_DIRECTORIES(${LIBS_PATH})
    ADD_LIBRARY(${TARGET_NAME} SHARED ${OUTPUTS})
    TARGET_LINK_LIBRARIES(${TARGET_NAME} ${LINK_ALL_LIBS})
    MESSAGE(STATUS "TARGET_LINK_LIBRARIES(${TARGET_NAME} ${LINK_ALL_LIBS})")

    # �������install��componentsĿ¼
    IF(WIN32)
        install_target(RUNTIME ${TARGET_NAME} components)
    ELSE()
        install_target(LIBRARY ${TARGET_NAME} components)
    ENDIF()

    #debuginfo
    MESSAGE(STATUS "GET NEED_DEBUGINFO = ${NEED_DEBUGINFO}")
    IF(NEED_DEBUGINFO)
        SET(TARGET_FULL_NAME ${CMAKE_SHARED_LIBRARY_PREFIX}${TARGET_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX})
        ADD_CUSTOM_COMMAND(TARGET ${TARGET_NAME}
                           COMMAND objcopy --only-keep-debug ${TARGET_FULL_NAME} ${TARGET_FULL_NAME}.debug
                           COMMAND objcopy --strip-debug ${TARGET_FULL_NAME}
                           COMMAND objcopy --add-gnu-debuglink=${TARGET_FULL_NAME}.debug ${TARGET_FULL_NAME}
                           WORKING_DIRECTORY ${LIBS_PATH}/components)
        LIST(APPEND DEBUGINFO_CLEAN_FILES ${LIBS_PATH}/components/${TARGET_FULL_NAME}.debug)
        install_files(debuginfo/components ${LIBS_PATH}/components/${TARGET_FULL_NAME}.debug)
    ENDIF()

ELSEIF("${TARGET_TYPE}" STREQUAL "")
    #���û��ָ����Ĭ�ϳ������ɶ�̬��
    MESSAGE(WARNING "(LINE:${CMAKE_CURRENT_LIST_LINE}) No giving generation type, try to create dynamic library")
    INCLUDE(link_library)
ENDIF()






# �Ƿ�����RES_FILES
MESSAGE(STATUS "GET RES_FILES = ${RES_FILES}")
IF(NOT "${RES_FILES}" STREQUAL "")
    ADD_CUSTOM_TARGET(${TARGET_NAME}_res ALL DEPENDS ${RES_FILES})
    ADD_DEPENDENCIES(${TARGET_NAME} ${TARGET_NAME}_res)

    MESSAGE(STATUS "ADD_DEPENDENCIES(${TARGET_NAME})")
    MESSAGE(STATUS "ADD_DEPENDENCIES(${TARGET_NAME}_res)")
ENDIF()



# �Ƿ�����target�汾
MESSAGE(STATUS "GET TARGET_VERSION = ${TARGET_VERSION}")
IF(NOT "${TARGET_VERSION}" STREQUAL "")
    SET_TARGET_PROPERTIES(${TARGET_NAME} PROPERTIES VERSION ${TARGET_VERSION})
ENDIF()


# �Զ������Ӳ���
MESSAGE(STATUS "GET CUSTOM_LDFLAGS = ${CUSTOM_LDFLAGS}")
IF (DEFINED CUSTOM_LDFLAGS)
    SET_TARGET_PROPERTIES(${TARGET_NAME} PROPERTIES LINK_FLAGS ${CUSTOM_LDFLAGS})
ENDIF ()





####################################################################################################
MESSAGE(STATUS "\n**custom_target----------------------------------------------------------------------")

# ����Զ�������
MESSAGE(STATUS "GET ENABLE_TARGET = ${ENABLE_TARGET}")

IF(${ENABLE_TARGET})
    #ÿ������ֻ��ִ��һ�Σ�����
    # add_custom_target(cleanall ...),�������target cleanall
    IF(WIN32)
        SET(MAKE_FLAGS /NOLOGO)
        MESSAGE(STATUS "SET MAKE_FLAGS = ${MAKE_FLAGS}")
    ENDIF()


    ADD_CUSTOM_TARGET(cleanall
                        COMMAND ${CMAKE_BUILD_TOOL} ${MAKE_FLAGS} clean
                        COMMAND ${CMAKE_COMMAND} -E remove -f ${PROJECT_BINARY_DIR}/CMakeCache.txt
                        COMMENT "Execute cleaning work, delete CMakeCache files !"
    )
    MESSAGE(STATUS "COMMAND ${CMAKE_BUILD_TOOL} ${MAKE_FLAGS} clean")
    MESSAGE(STATUS "COMMAND ${CMAKE_COMMAND} -E remove -f ${PROJECT_BINARY_DIR}/CMakeCache.txt")
    MESSAGE(STATUS "COMMENT Execute cleaning work, delete CMakeCache files !")


    # add_custom_target(cleancache ...),�������target cleancache
    ADD_CUSTOM_TARGET(cleancache
                        COMMAND ${CMAKE_COMMAND} -E remove -f ${PROJECT_BINARY_DIR}/CMakeCache.txt
                        COMMENT "delete CMakeCache files !"
    )
    MESSAGE(STATUS "COMMAND ${CMAKE_COMMAND} -E remove -f ${PROJECT_BINARY_DIR}/CMakeCache.txt")
    MESSAGE(STATUS "COMMENT delete CMakeCache files !")
ENDIF()







####################################################################################################
MESSAGE(STATUS "\n**add make clean-------------------------------------------------------------------")


# do additional `make clean`
# ��ӱ���IDL�ļ�����ļ���mo�ļ��͵�`make clean`ѡ��Ա�`make clean `���
SET(ADDITIONAL_CLEAN_FILES ${RES_CLEAN_FILES};
                           ${IDL_CLEAN_FILES};
                           ${THRIFT_CLEAN_FILES};
                           ${DEBUGINFO_CLEAN_FILES})
MESSAGE(STATUS "SET ADDITIONAL_CLEAN_FILES = ${ADDITIONAL_CLEAN_FILES}")

SET_DIRECTORY_PROPERTIES(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${ADDITIONAL_CLEAN_FILES}")




####################################################################################################
MESSAGE(STATUS "\n**package-------------------------------------------------------------------------")

# ���
MESSAGE(STATUS "GET ENABLE_PACKAGE = ${ENABLE_PACKAGE}")
IF(ENABLE_PACKAGE)
    IF(WIN32)
        SET(CPACK_OUTPUT_FILE_PREFIX ${PACKAGE_PATH})
        # ���ô����ʽ
        SET(CPACK_SOURCE_GENERATOR "ZIP")
        SET(CPACK_GENERATOR "ZIP")
    ELSE()
        SET(CPACK_OUTPUT_FILE_PREFIX ${PACKAGE_PATH})
        # ���ô����ʽ
        SET(CPACK_SOURCE_GENERATOR "TGZ")
        SET(CPACK_GENERATOR "TGZ")
    ENDIF()
    SET(CPACK_DEBIAN_PACKAGE_MAINTAINER ${CMAKE_PROJECT_NAME})

    MESSAGE(STATUS "SET CPACK_OUTPUT_FILE_PREFIX = ${CPACK_OUTPUT_FILE_PREFIX}")
    MESSAGE(STATUS "SET CPACK_SOURCE_GENERATOR = ${CPACK_SOURCE_GENERATOR}")
    MESSAGE(STATUS "SET CPACK_GENERATOR = ${CPACK_GENERATOR}")
    MESSAGE(STATUS "SET CPACK_DEBIAN_PACKAGE_MAINTAINER = ${CPACK_DEBIAN_PACKAGE_MAINTAINER}")

    # ��ȡʱ��
    TODAY(tdate)
    MESSAGE(STATUS "GET tdate = ${tdate}")

    # ���ô���İ汾�źͰ汾
    # package
    MESSAGE(STATUS "GET CPACK_PACKAGE_FILE_NAME = ${CPACK_PACKAGE_FILE_NAME}")
    MESSAGE(STATUS "GET CPACK_PACKAGE_NAME = ${CPACK_PACKAGE_NAME}")
    MESSAGE(STATUS "GET CPACK_PACKAGE_VERSION = ${CPACK_PACKAGE_VERSION}")
    MESSAGE(STATUS "GET CPACK_PACKAGE_TYPE = ${CPACK_PACKAGE_TYPE}")
    IF(DEFINED CPACK_PACKAGE_FILE_NAME)
        # �������CPACK_PACKAGE_FILE_NAME,nothing to do

    ELSEIF((DEFINED CPACK_PACKAGE_NAME) AND (DEFINED CPACK_PACKAGE_VERSION))
            IF(DEFINED CPACK_PACKAGE_TYPE)
                SET(CPACK_PACKAGE_FILE_NAME ${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${tdate}-${CPACK_PACKAGE_TYPE})
                MESSAGE(STATUS "SET CPACK_PACKAGE_FILE_NAME = ${CPACK_PACKAGE_FILE_NAME}")
            ELSE()
                SET(CPACK_PACKAGE_FILE_NAME ${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${tdate}-${CMAKE_BUILD_TYPE})
                MESSAGE(STATUS "SET CPACK_PACKAGE_FILE_NAME = ${CPACK_PACKAGE_FILE_NAME}")
            ENDIF()
    ELSE()
        #to do or not to do,define the package name ?
    ENDIF()

    #source package
    MESSAGE(STATUS "GET CPACK_SOURCE_PACKAGE_NAME = ${CPACK_SOURCE_PACKAGE_NAME}")
    IF(DEFINED CPACK_PACKAGE_FILE_NAME)
        # nothing to do
    ELSEIF((DEFINED CPACK_SOURCE_PACKAGE_NAME) AND (DEFINED CPACK_PACKAGE_VERSION))
        IF(DEFINED CPACK_PACKAGE_TYPE)
            SET(CPACK_SOURCE_PACKAGE_FILE_NAME ${CPACK_SOURCE_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${tdate}-${CMAKE_BUILD_TYPE})
            MESSAGE(STATUS "SET CPACK_SOURCE_PACKAGE_FILE_NAME = ${CPACK_SOURCE_PACKAGE_FILE_NAME}")
        ELSE()
            SET(CPACK_SOURCE_PACKAGE_FILE_NAME ${CPACK_SOURCE_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${tdate}-${CPACK_PACKAGE_TYPE})
            MESSAGE(STATUS "SET CPACK_SOURCE_PACKAGE_FILE_NAME = ${CPACK_SOURCE_PACKAGE_FILE_NAME}")
        ENDIF()
    ELSE()
        #to do or not to do,define the package_source name ?
    ENDIF()

    # INCLUDEӦ�÷������
    #C:\Program Files\CMake\share\cmake-3.7\Modules\CPack.cmake
    INCLUDE(CPack)
ENDIF()


####################################################################################################
MESSAGE(STATUS "\n**target.cmake end----------------------------------------------------------------")

MESSAGE(STATUS "GET CMAKE_CXX_FLAGS_DEBUG = ${CMAKE_CXX_FLAGS_DEBUG}")
MESSAGE(STATUS "GET CMAKE_CXX_FLAGS_RELEASE = ${CMAKE_CXX_FLAGS_RELEASE}")
MESSAGE(STATUS "GET CMAKE_CXX_FLAGS = ${CMAKE_CXX_FLAGS}")
MESSAGE(STATUS "GET CMAKE_EXE_LINKER_FLAGS = ${CMAKE_EXE_LINKER_FLAGS}")
MESSAGE(STATUS "GET CMAKE_EXE_LINKER_FLAGS_RELEASE = ${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
MESSAGE(STATUS "GET CMAKE_SHARED_LINKER_FLAGS = ${CMAKE_SHARED_LINKER_FLAGS}")
MESSAGE(STATUS "GET CMAKE_SHARED_LINKER_FLAGS_RELEASE = ${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
MESSAGE(STATUS "GET CMAKE_STATIC_LINKER_FLAGS = ${CMAKE_STATIC_LINKER_FLAGS}")

####################################################################################################
MESSAGE(STATUS "\n**target.cmake end----------------------------------------------------------------")
MESSAGE(STATUS "")
MESSAGE(STATUS "")





