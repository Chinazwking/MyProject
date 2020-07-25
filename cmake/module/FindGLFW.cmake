MESSAGE(STATUS "GLFW is used")
ADD_DEFINITIONS(-D__USING_GLFW__)

# ����ͷ�ļ�·�������ӿ�
INCLUDE_DIRECTORIES(${MYDEPS}/glfw/include)

SET(GLFW_LIB glfw)

SET(LIB_GLFW_PATH ${MYDEPS}/glfw/lib/${MYPLATFORM})
seek_deps_library(${LIBS_PATH} ${LIB_GLFW_PATH} ${GLFW_LIB})

SET(LINK_GLFW_LIBS ${GLFW_LIB})
