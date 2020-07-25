MESSAGE(STATUS "\n**include tailer.cmake\n")

MESSAGE(STATUS "\n**deps----------------------------------------------")

# 检查是否存在config目录，并将目录下的文件生成到lib库所在目录
# 仅拷贝，顾配置文件可以放在config目录中
SET(DEFAULT_CONFIG_PATH ${CMAKE_CURRENT_SOURCE_DIR}/config)
MESSAGE(STATUS "SET DEFAULT_CONFIG_PATH = ${DEFAULT_CONFIG_PATH}")
IF(EXISTS ${DEFAULT_CONFIG_PATH})
    FILE(INSTALL ${DEFAULT_CONFIG_PATH} DESTINATION ${LIBS_PATH})
ENDIF()
IF(EXISTS ${NEED_COPY_PATH})
    MESSAGE(STATUS "NEED_COPY_PATH = ${NEED_COPY_PATH}")
    FILE(INSTALL ${NEED_COPY_PATH} DESTINATION ${LIBS_PATH})
ENDIF()

# 检查资源文件
SET(DEFAULT_RESOURCE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../resource)
MESSAGE(STATUS "SET DEFAULT_RESOURCE_PATH = ${DEFAULT_RESOURCE_PATH}")
IF(EXISTS ${DEFAULT_RESOURCE_PATH})
    FILE(INSTALL ${DEFAULT_RESOURCE_PATH}/ DESTINATION ${LIBS_PATH} PATTERN ".svn" EXCLUDE)
    install_dir(${DEFAULT_RESOURCE_PATH}/ "")
    MESSAGE(STATUS "install_dir(${DEFAULT_RESOURCE_PATH})")
ENDIF()

# 检查是否存在service目录,并将目录文件拷贝到生成lib库所在的目录下
# 仅仅有拷贝的动作，故服务文件可以放置在各模块所在的service目录
SET(DEFAULT_SERVICE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/service)
MESSAGE(STATUS "SET DEFAULT_SERVICE_PATH = ${DEFAULT_SERVICE_PATH}")
IF(EXISTS ${DEFAULT_SERVICE_PATH})
    FILE(INSTALL ${DEFAULT_SERVICE_PATH} DESTINATION ${LIBS_PATH})
ENDIF()

# 检查目录下是否由image文件
SET(DEFAULT_IMAGES_PATH ${CMAKE_CURRENT_SOURCE_DIR}/images)
MESSAGE(STATUS "SET DEFAULT_IMAGES_PATH = ${DEFAULT_IMAGES_PATH}")
IF(EXISTS ${DEFAULT_IMAGES_PATH})
    FILE(INSTALL ${DEFAULT_IMAGES_PATH} DESTINATION ${LIBS_PATH})
ENDIF()
MESSAGE(STATUS "\n\n**include:target.cmake\n")

# 设置依赖库选项

# 配置boost库依赖
IF(${NEED_BOOST})
    FIND_PACKAGE(boost REQUIRED)
ENDIF()

# 配置Gtest依赖
IF(${NEED_GTEST})
    FIND_PACKAGE(gtest REQUIRED)
ENDIF()

# 配置GLFW依赖
IF(${NEED_GLFW})
    FIND_PACKAGE(glfw REQUIRED)
ENDIF()

# 配置stb_image依赖
IF(${NEED_STB_IMAGE})
    FIND_PACKAGE(stbimage REQUIRED)
ENDIF()

# 配置sdl2 相关依赖
IF(${NEED_SDL2})
    FIND_PACKAGE(SDL2 REQUIRED)
ENDIF()

# 配置Assimp依赖
IF(${NEED_ASSIMP})
    FIND_PACKAGE(Assimp REQUIRED)
ENDIF()

# 配置freetype依赖
IF(${NEED_FREETYPE})
    FIND_PACKAGE(freetype REQUIRED)
ENDIF()

IF(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/../public)
    GET_FILENAME_COMPONENT(PARENT_PATH ${CMAKE_CURRENT_SOURCE_DIR} PATH)
    # 设置自定义idl路径
    SET(CUSTOM_IDL_PATH ${PARENT_PATH}/public;
                        ${PARENT_PATH})
ENDIF()

IF(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/../private)
    # 设置自定义的 IDL 路径
    GET_FILENAME_COMPONENT(PARENT_PATH ${CMAKE_CURRENT_SOURCE_DIR} PATH)
    SET(CUSTOM_IDL_PATH ${PARENT_PATH}/private
                        ${CUSTOM_IDL_PATH})
ENDIF()

# 注意：每次添加新的NEED_XXX依赖后，如果有需要链接新的依赖库，需要将最后的变量加入LINK_ALL_LIBS变量内。
# 设置所有的链接库

SET(LINK_ALL_LIBS   ${LINK_SDL2_LIBS}
                    ${LINK_GTEST_LIBS}
                    ${LINK_GLFW_LIBS}
                    ${LINK_STB_IMAGE_LIBS}
                    ${LINK_ASSIMP_LIBS}
                    ${LINK_FREETYPE_LIBS}
                    )

MESSAGE(STATUS "SET LINK_ALL_LIBS = ${LINK_ALL_LIBS}")

MESSAGE(STATUS "\n**compile_IDL----------------------------------------------")

## 检查是否有IDL文件需要编译
IF(DEFINED CUSTOM_IDL_PATH)

    # 注:为加快编译,public的目录下若已生成.h和.xpt文件，则不会再次编译idl文件.
    # 若要手动重新编译idl文件，请先执行`make clean`,然后执行 `cmake xxx`

    # 设置IDL文件搜索路径

    SET(DEFAULT_IDL_PATH ${DEFAULT_IDL_PATH};${CUSTOM_IDL_PATH})
    MESSAGE(STATUS "SET DEFAULT_IDL_PATH = ${DEFAULT_IDL_PATH}")

    # 将目录添加到idl
    FOREACH(EACH_DEPS_IDL_PATH ${DEFAULT_IDL_PATH})
        LIST(APPEND DEPS_IDL_PATH "-I${EACH_DEPS_IDL_PATH}")
    ENDFOREACH()

    LIST(REMOVE_DEPLICATES DEPS_IDL_PATH)
    LIST(REMOVE_DEPLICATES DEFAULT_IDL_PATH)
    MESSAGE(STATUS "GET DEPS_IDL_PATH = ${DEPS_IDL_PATH}")
    MESSAGE(STATUS "GET DEFAULT_IDL_PATH = ${DEFAULT_IDL_PATH}")

    # 设置idl可执行文件路径
    IF(WIN32)
        SET(XPIDL_NAME xpidl.exe)
        MESSAGE(STATUS "SET XPIDL_NAME = ${XPIDL_NAME}")
    ENDIF()

    # 编译idl文件
    IF(EXISTS ${MYDEPS}/xpidl/bin/${MYPLATFORM}/${CMAKE_BUILD_TYPE}/${XPIDL_NAME})
        SET(XPIDL ${ABDEPS}/xpidl/bin/${MYPLATFORM}/${CMAKE_BUILD_TYPE}/${XPIDL_NAME})
        MESSAGE(STATUS "SET XPIDL = ${XPIDL}")

        IF(NOT WIN32)
            EXECUTE_PROCESS(COMMAND chmod +x ${XPIDL})
        ENDIF()
    ELSE()
        MESSAGE(WARNING "(LINE:${CMAKE_CURRENT_LIST_LINE} NOT FOUND EXECUTABLE ${XPIDL_NAME} AND ${XPTLINK_NAME}")
    ENDIF()

    MESSAGE(STATUS "COMPILE IDL FILES...")

    FOREACH(EACH_IDL_PATH ${DEFAULT_IDL_PATH})
        MESSAGE(STATUS "GET EACH_IDL_PATH = ${EACH_IDL_PATH}")

        # glob返回绝对路径
        FILE(GLOB IDL_FILES "${EACH_IDL_PATH}/*.idl")
        FILE(GLOB IDL_H_FILES "${EACH_IDL_PATH}/*.h")
        IF(NOT "${IDL_FILES}" STREQUAL "")
            FOREACH(_IN_FILE ${IDL_FILES})
                GET_FILENAME_COMPONENT(_OUT_FILE ${_IN_FILE} NAME_WE)
                GET_FILENAME_COMPONENT(_IN_PATH ${_IN_FILE} PATH)
                GET_FILENAME_COMPONENT(_OUT_NAME ${_IN_PATH} NAME)
                SET(_OUT_PATH ${PROJECT_BINARY_DIR}/${_OUT_NAME})
                FILE(MAKE_DIRECTORY ${_OUT_PATH})
                INCLUDE_DIRECTORIES(${_OUT_PATH})
                INCLUDE_DIRECTORIES(${PROJECT_BINARY_DIR})

                #跟踪每个idl文件是否编译
                ADD_CUSTOM_COMMAND(OUTPUT ${_OUT_PATH}/${_OUT_FILE}.h
                    COMMAND ${XPIDL}
                    ARGS ${DEPS_IDL_PATH}
                    -m header -w -v -e ${_OUT_PATH}/${_OUT_FILE}.h ${_IN_FILE}
                    WORKING_DIRECTORY ${_IN_PATH}
                    COMMENT "")

                LIST(APPEND IDL_HEADER_FILES ${_OUT_PATH}/${_OUT_FILE}.h)
                LIST(APPEND IDL_CLEAN_FILES ${_OUT_PATH}/${_OUT_FILE}.H)
            ENDFOREACH(_IN_FILE)

            SET_SOURCE_FILES_PROPERTIES(${IDL_HEADER_FILES} PROPERTIES GENERATED TRUE)
            # 不懂
            SET(${IDL_HEADER_FILES} ${IDL_HEADER_FILES})
        ENDIF()
    ENDFOREACH(EACH_IDL_PATH)

    # success
    MESSAGE(STATUS "COMPILE IDL FILES SUCCESS...")

    # 清除变量
    UNSET(DEPS_IDL_PATH)
    UNSET(DEFAULT_IDL_PATH)
ENDIF()

MESSAGE(STATUS "\n**info----------------------------------------------")

MESSAGE(STATUS "GET AUTO_RUN = ${AUTO_RUN}")

MESSAGE(STATUS "GET CMAKE_SYSTEM_NAME = ${CMAKE_SYSTEM_NAME}")
MESSAGE(STATUS "GET CMAKE_SYSTEM = ${CMAKE_SYSTEM}")
MESSAGE(STATUS "GET CMAKE_SYSTEM_VERSION = ${CMAKE_SYSTEM_VERSION}")
MESSAGE(STATUS "GET CMAKE_SYSTEM_PROCESSOR = ${CMAKE_SYSTEM_PROCESSOR}")
MESSAGE(STATUS "GET PROJECT_NAME = ${PROJECT_NAME}")
MESSAGE(STATUS "GET CMAKE_BUILD_TYPE = ${CMAKE_BUILD_TYPE}")
MESSAGE(STATUS "GET TARGET_TYPE = ${TARGET_TYPE}")
MESSAGE(STATUS "GET CMAKE_BUILD_VERSION = ${CMAKE_BUILD_VERSION}")
MESSAGE(STATUS "GET PROJECT_BINARY_DIR = ${CMAKE_BUILD_VERSION}")
MESSAGE(STATUS "...")


MESSAGE(STATUS "\n**get_sourcefiles----------------------------------------------")

# 获取当前目录及其子目录下的所有源文件
SET(SRC "")
FOREACH(SUBDIR ${SOURCE_DIRS})
    IF(EXISTS ${SUBDIR}/res)
        IF(NOT DEFINED RES_TARGET_NAME)
            SET(RES_TARGET_NAME "-")
        ENDIF()
        # 生成mo文件
        ADD_RES_FILES_TARGET(${SUBDIR}/res ${LIBS_PATH} EACH_RES_CLEAN_FILES ${RES_TARGET_NAME})
    ENDIF()

    # find all source file in dir
    AUX_SOURCE_DIRECTORY(${SUBDIR} SUBDIR_SRC)

    MESSAGE(STATUS "GET SUBDIR_SRC ${SUBDIR_SRC}")
    SET(SRC ${SRC} ${SUBDIR_SRC})
    SET(RES_CLEAN_FILES ${RES_CLEAN_FILES} ${EACH_RES_CLEAN_FILES})
    SET(SUBDIR_SRC "")
    SET(EACH_RES_CLEAN_FILES "")
ENDFOREACH()

# 获取所有源文件,并统一处理成已绝对路径显示的文件名,以便进行文件过滤
SET(ALLSRCS ${SRC} ${INCLUDE_SOURCE_FILES})
SET(ALL_SOURCES "")

FOREACH(_ALLSRC ${ALLSRCS})
    GET_FILENAME_COMPONENT(_ALLSRC_PATH ${_ALLSRC} PATH)
    GET_FILENAME_COMPONENT(_ALLSRC_NAME ${_ALLSRC} NAME)

    # 为空代表当前路径
    IF("${_ALLSRC_PATH}" STREQUAL "")
        SET(ALL_SOURCES ${ALL_SOURCES} ${CMAKE_CURRENT_SOURCE_DIR}/${_ALLSRC})
    ELSEIF("${_ALLSRC_PATH}" STREQUAL ".")
        SET(ALL_SOURCES ${ALL_SOURCES} ${CMAKE_CURRENT_SOURCE_DIR}/${_ALLSRC_NAME})
    ELSEIF(IS_ABSOLUTE ${_ALLSRC_PATH})
        SET(ALL_SOURCES ${ALL_SOURCES} ${_ALLSRC})
    ELSE()
        SET(ALL_SOURCES ${ALL_SOURCES} ${CMAKE_CURRENT_SOURCE_DIR}/${_ALLSRC})
    ENDIF()
ENDFOREACH()

# 过滤掉不需要的编译文件
IF("${EXCLUDE_SOURCE_FILES}" STREQUAL "")
    SET(OUTPUTS ${ALL_SOURCES}
                ${THRIFT_GEN_CPP_HDRS}
                ${THRIFT_GEN_CPP_SRCS}
                ${IDL_HEADER_FILES})
ELSE()
    SET(ALL_EXCLUDE_SOURCE_FILES "")
    FOREACH(_EXCLUDE_SOURCE_FILE ${EXCLUDE_SOURCE_FILES})
        GET_FILENAME_COMPONENT(_EXCLUDE_SOURCE_FILE_PATH ${_EXCLUDE_SOURCE_FILE} PATH)
        GET_FILENAME_COMPONENT(_EXCLUDE_SOURCE_FILE_NAME ${_EXCLUDE_SOURCE_FILE} NAME)

        IF("${_EXCLUDE_SOURCE_FILE_PATH}" STREQUAL "")
            SET(ALL_EXCLUDE_SOURCE_FILES ${ALL_EXCLUDE_SOURCE_FILES} ${CMAKE_CURRENT_SOURCE_DIR}/${_EXCLUDE_SOURCE_FILE})
        ELSEIF("${_EXCLUDE_SOURCE_FILE_PATH}" STREQUAL ".")
            SET(ALL_EXCLUDE_SOURCE_FILES ${ALL_EXCLUDE_SOURCE_FILES} ${CMAKE_CURRENT_SOURCE_DIR}/${_EXCLUDE_SOURCE_FILE_NAME})
        ELSEIF(IS_ABSOLUTE ${_EXCLUDE_SOURCE_FILE_PATH})
            SET(ALL_EXCLUDE_SOURCE_FILES ${ALL_EXCLUDE_SOURCE_FILES} ${_EXCLUDE_SOURCE_FILE})
        ELSE()
            SET(ALL_EXCLUDE_SOURCE_FILES ${ALL_EXCLUDE_SOURCE_FILES} ${CMAKE_CURRENT_SOURCE_DIR}/${_EXCLUDE_SOURCE_FILE})
        ENDIF()
    ENDFOREACH()

    #过滤掉不需要编译的文件
    FILTER_OUT("${ALL_EXCLUDE_SOURCE_FILES}" "${ALL_SOURCES}" OUTPUTS)

    SET(OUTPUTS ${ALL_SOURCES}
                ${THRIFT_GEN_CPP_HDRS}
                ${THRIFT_GEN_CPP_SRCS}
                ${IDL_HEADER_FILES})
ENDIF()

MESSAGE(STATUS "SET ALL_EXCLUDE_SOURCE_FILES = ${ALL_EXCLUDE_SOURCE_FILES}")
MESSAGE(STATUS "SET OUTPUTS = ${OUTPUTS}")


MESSAGE(STATUS "\n**link_target----------------------------------------------")

#  链接
# 设置所有生成库和可执行文件的路径，在此统一所有输出路径。
# 设置不同的CMAKE_GENERATOR的生成目标路径(解决MSVC会自动创建Debug和Release目录)

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
    STRING(TOUPPER ${OUTPUTCONFIG} OUTPUTCONFIG)
    SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${LIBS_PATH})
    SET(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${LIBS_PATH})
    SET(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${LIBS_PATH})
ENDFOREACH()

# link类型
MESSAGE(STATUS "GET TARGET_TYPE = ${TARGET_TYPE}")
MESSAGE(STATUS "GET TARGET_NAME = ${TARGET_NAME}")
IF("${TARGET_TYPE}" STREQUAL "RUNTIME")
    IF(WIN32)
        IF("${SUBSYSTEM}" STREQUAL "WINDOWS")
            SET(EXPECT_LINK_FLAG WIN32)
            MESSAGE(STATUS "SET EXPECT_LINK_FLAG = ${EXPECT_LINK_FLAG}")
        ENDIF()
        IF(NOT MSVC_2015)
            SET(CUSTOM_LDFLAGS "${CUSTOM_LDFLAGS} /MANIFESTUAC:\"level='requireAdministrator' uiAccess='false'\"")
            MESSAGE(STATUS "SET CUSTOM_LDFLAGS = ${CUSTOM_LDFLAGS}")
        ENDIF()
    ELSEIF(DARWIN)
        SET(EXPECT_LINK_FLAG "MACOSX_BUNDLE")
    ENDIF()

    LINK_DIRECTORIES(${LIBS_PATH})
    ADD_EXECUTABLE(${TARGET_NAME} ${EXPECT_LINK_FLAG} ${OUTPUTS})
    IF(NOT "${LINK_ALL_LIBS}" STREQUAL "")
        TARGET_LINK_LIBRARIES(${TARGET_NAME} ${LINK_ALL_LIBS})
        MESSAGE(STATUS "TARGET_LINK_LIBRARIES(${TARGET_NAME} ${LINK_ALL_LIBS})")
    ENDIF()

    #debuginfo
    MESSAGE(STATUS "GET NEED_DEBUGINFO = ${NEED_DEBUGINFO}")
    IF(NEED_DEBUGINFO)
        SET(TARGET_FULL_NAME ${TARGET_NAME})
        ADD_CUSTOM_COMMAND(TARGET ${TARGET_NAME}
            COMMAND objcopy --only-keep-debug ${TARGET_FULL_NAME} ${TARGET_FULL_NAME}.debug
            COMMAND objcopy --strip-debug ${TARGET_FULL_NAME}
            COMMAND objcopy --add-gnu-debuglink=${TARGET_FULL_NAME}.debug ${TARGET_FULL_NAME}
            WORKING_DIRECTORY ${LIBS_PATH})
        LIST(APPEND DEBUGINFO_CLEAN_FILES ${LIBS_PATH}/{TARGET_FULL_NAME}.debug)
        INSTALL_FILES(debuginfo ${LIBS_PATH}/${TARGET_FULL_NAME}.debug)
    ENDIF()

    #判断是否自动执行，由AUTO_RUN来开启和关闭
    IF(WIN32)
        SET(RUN_NAME ${TARGET_NAME}.exe)
        IF(AUTO_RUN)
            ADD_CUSTOM_TARGET(RUN_${TARGET_NAME} ALL
                COMMAND start /WAIT ${RUN_NAME}
                DEPENDS ${TARGET_NAME}
                WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
                COMMENT "RUNNING ${RUN_NAME} ...")
        ELSE()
            ADD_CUSTOM_TARGET(RUN_${TARGET_NAME}
                COMMAND start /WAIT ${RUN_NAME}
                DEPENDS ${TARGET_NAME}
                WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
                COMMENT "RUNNING ${RUN_NAME} ...")
        ENDIF()
    ELSE()
        SET(RUN_NAME ${TARGET_NAME})
        IF(AUTO_RUN)
            ADD_CUSTOM_TARGET(RUN_${TARGET_NAME} ALL
                COMMAND ${RUN_NAME} ${RUN_ARGS}
                DEPENDS ${TARGET_NAME}
                WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
                COMMENT "RUNNING ${RUNNING} ...")
        ENDIF()
    ENDIF()
ELSEIF("${TARGET_TYPE}" STREQUAL "LIBRARY")
    # 连接成动态库
    LINK_DIRECTORIES(${LIBS_PATH})
    ADD_LIBRARY(${TARGET_NAME} SHARED ${OUTPUTS})
    IF(NOT "${LINK_ALL_LIBS}" STREQUAL "")
        TARGET_LINK_LIBRARIES(${TARGET_NAME} ${LINK_ALL_LIBS})
        MESSAGE(STATUS "TARGET_LINK_LIBRARIES(${TARGET_NAME} ${LINK_ALL_LIBS})")
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
    # 链接成为静态库
    LINK_DIRECTORIES(${LIBS_PATH})
    ADD_LIBRARY(${TARGET_NAME} STATIC ${OUTPUTS})
    IF(NOT "${LINK_ALL_LIBS}" STREQUAL "")
        TARGET_LINK_LIBRARIES(${TARGET_NAME} ${LINK_ALL_LIBS})
        MESSAGE(STATUS "TARGET_LINK_LIBRARIES(${TARGET_NAME} ${LINK_ALL_LIBS})")
    ENDIF()
ELSEIF("${TARGET_TYPE}" STREQUAL "COMPONENT")
    # 链接成为一个组件库
    # 将其存放在components里

    # First for the generic no-config case (e.g. with mingw)
    SET(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${LIBS_PATH}/components)
    SET(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${LIBS_PATH}/components)
    SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${LIBS_PATH}/components)

    # Second, for multi-config builds (e.g. msvc)
    FOREACH(OUTPUTCONFIG ${CMAKE_CONFIGURATION_TYPES})
        STRING(TOUPPER ${OUTPUTCONFIG} OUTPUTCONFIG)
        SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${LIBS_PATH}/components)
        SET(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${LIBS_PATH}/components)
        SET(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${LIBS_PATH}/components)
    ENDFOREACH()

    # 连接成动态库
    LINK_DIRECTORIES(${LIBS_PATH})
    ADD_LIBRARY(${TARGET_NAME} SHARED ${OUTPUTS})
    IF(NOT "${LINK_ALL_LIBS}" STREQUAL "")
        TARGET_LINK_LIBRARIES(${TARGET_NAME} ${LINK_ALL_LIBS})
        MESSAGE(STATUS "TARGET_LINK_LIBRARIES(${TARGET_NAME} ${LINK_ALL_LIBS})")
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
    ENDIF()
ELSE()
    MESSAGE(WARNING "(LINE:${CMAKE_CURRENT_LIST_LINE}) No giving generation type")
ENDIF()

# 是否设置RES_FILES
MESSAGE(STATUS "GET RES_FILES = ${RES_FILES}")
IF(NOT "${RES_FILES}" STREQUAL "")
    ADD_CUSTOM_TARGET(${TARGET_NAME}_res ALL DEPENDS ${RES_FILES})
    ADD_DEPENDENCIES(${TARGET_NAME} ${TARGET_NAME}_res)

    MESSAGE(STATUS "ADD_DEPENDENCIES(${TARGET_NAME})")
    MESSAGE(STATUS "ADD_DEPENDENCIES(${TARGET_NAME}_res)")
ENDIF()

# 是否设置target版本
MESSAGE(STATUS "GET TARGET_VERSION = ${TARGET_VERSION}")
IF(NOT "${TARGET_VERSION}" STREQUAL "")
    SET_TARGET_PROPERTIES(${TARGET_NAME} PROPERTIES VERSION ${TARGET_VERSION})
ENDIF()

# 自定义链接参数
MESSAGE(STATUS "GET CUSTOM_LDFLAGS = ${CUSTOM_LDFLAGS}")
IF(DEFINED CUSTOM_LDFLAGS)
    SET_TARGET_PROPERTIES(${TARGET_NAME} PROPERTIES LINK_FLAGS ${CUSTOM_LDFLAGS})
ENDIF()

MESSAGE(STATUS "\n**custom_target----------------------------------------------")

MESSAGE(STATUS "GET ENABLE_TARGET = ${ENABLE_TARGET}")

IF(${ENABLE_TARGET})
    #每个命令只能执行一次，慎用
    # add_custom_target(cleanall ...),用来添加target cleanall
    IF(WIN32)
        SET(MAKE_FLAGS /NOLOGO)
        MESSAGE(STATUS "SET MAKE_FLAGS = ${MAKE_FLAGS}")
    ENDIF()

    ADD_CUSTOM_TARGET(cleanall
        COMMAND ${CMAKE_BUILD_TOOL} ${MAKE_FLAGS} clean
        COMMAND ${CMAKE_COMMAND} -E remove -f ${PROJECT_BINARY_DIR}/CMakeCache.txt
        COMMENT "Execute cleaning work, delete CMakeCache files !")

    MESSAGE(STATUS "COMMAND ${CMAKE_BUILD_TOOL} ${MAKE_FLAGS} clean")
    MESSAGE(STATUS "COMMAND ${CMAKE_COMMAND} -E remove -f ${PROJECT_BINARY_DIR}/CMakeCache.txt")
    MESSAGE(STATUS "COMMENT Execute cleaning work, delete CMakeCache files !")

    ADD_CUSTOM_TARGET(cleancache
        COMMAND ${CMAKE_COMMAND} -E remove -f ${PROJECT_BINARY_DIR}/CmakeCache.txt
        COMMENT "DELETE CMakeCache.txt")
    MESSAGE(STATUS "COMMENT delete CMakeCache files !")
ENDIF()

MESSAGE(STATUS "\n**add make clean----------------------------------------------")

# do additional `make clean`
# 添加编译IDL文件后的文件、mo文件和到`make clean`选项，以便`make clean `清除
SET(ADDITIONAL_CLEAN_FILES ${RES_CLEAN_FILES};
                           ${IDL_CLEAN_FILES};
                           ${THRIFT_CLEAN_FILES};
                           ${DEBUGINFO_CLEAN_FILES})
MESSAGE(STATUS "SET ADDITIONAL_CLEAN_FILES = ${ADDITIONAL_CLEAN_FILES}")

SET_DIRECTORY_PROPERTIES(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${ADDITIONAL_CLEAN_FILES}")

MESSAGE(STATUS "\n**extra info----------------------------------------------")

MESSAGE(STATUS "GET CMAKE_CXX_FLAGS_DEBUG = ${CMAKE_CXX_FLAGS_DEBUG}")
MESSAGE(STATUS "GET CMAKE_CXX_FLAGS_RELEASE = ${CMAKE_CXX_FLAGS_RELEASE}")
MESSAGE(STATUS "GET CMAKE_CXX_FLAGS = ${CMAKE_CXX_FLAGS}")
MESSAGE(STATUS "GET CMAKE_EXE_LINKER_FLAGS = ${CMAKE_EXE_LINKER_FLAGS}")
MESSAGE(STATUS "GET CMAKE_EXE_LINKER_FLAGS_RELEASE = ${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
MESSAGE(STATUS "GET CMAKE_SHARED_LINKER_FLAGS = ${CMAKE_SHARED_LINKER_FLAGS}")
MESSAGE(STATUS "GET CMAKE_SHARED_LINKER_FLAGS_RELEASE = ${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
MESSAGE(STATUS "GET CMAKE_STATIC_LINKER_FLAGS = ${CMAKE_STATIC_LINKER_FLAGS}")

####################################################################################################
MESSAGE(STATUS "\n**tailer end----------------------------------------------")
