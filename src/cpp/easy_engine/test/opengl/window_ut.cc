// opengl_ut.cc - 所有的opengl相关ut
// Version: 1.0
// Author: Wang Zhuowei wang.zhuowei@foxmail.com
// Copyright: (c) wang.zhuowei@foxmail.com All rights reserved.
// Last Change: 2020  8 12
// License: GPL.v3

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>
#include <gtest/gtest.h>

#include <boost/format.hpp>
#include <ctime>
#include <iostream>
#include <memory>

#include "common/timer.h"
#include "graphics/camera.h"
#include "graphics/font.h"
#include "graphics/particle.h"
#include "graphics/sprite.h"
#include "opengl/framebuffer.h"
#include "opengl/shader.h"
#include "opengl/window.h"
#include "utility/config.h"

using boost::format;
using namespace easy_engine;
using namespace easy_engine::utility;
using namespace easy_engine::opengl;
using namespace easy_engine::graphics;
using std::cout;
using std::endl;

namespace {
const int SCREEN_WIDTH    = 800;
const int SCREEN_HEIGHT   = 600;
const int PARTICLE_AMOUNT = 500;

void Pos(GLFWwindow* w, double x, double y) {
  cout << format("x=%f, y=%f") % x % y << endl;
}
void Btn(GLFWwindow* w, int k, int a, int m) {
  cout << format("key=%d, action=%d, mods=%d") % k % a % m << endl;
}
void Key(GLFWwindow* w, int k, int s, int a, int m) {
  cout << format("key=%d, scancode=%d, action=%d, mods=%d") % k % s % a % m
       << endl;
}

// 摄像机
std::shared_ptr<Camera2D> g_camera(
    new Camera2D(vec2(0, SCREEN_HEIGHT), vec2(SCREEN_WIDTH, SCREEN_HEIGHT)));

// 处理摄像机移动的回调函数
void ProcessInputCam(GLFWwindow* w, int k, int s, int a, int m) {
  static vec2 start(450, 350);
  if (glfwGetKey(w, GLFW_KEY_W) == GLFW_PRESS) {
    g_camera->MoveCentral(start += vec2(0, -10));
  }
  if (glfwGetKey(w, GLFW_KEY_S) == GLFW_PRESS) {
    g_camera->MoveCentral(start += vec2(0, 10));
  }
  if (glfwGetKey(w, GLFW_KEY_D) == GLFW_PRESS) {
    g_camera->MoveCentral(start += vec2(10, 0));
  }
  if (glfwGetKey(w, GLFW_KEY_A) == GLFW_PRESS) {
    g_camera->MoveCentral(start += vec2(-10, 0));
  }
}

// 模拟对象
Particle dummy_obj;

// 处理对象移动的回掉函数
void ProcessInputObj(GLFWwindow* w, int k, int s, int a, int m) {
  if (glfwGetKey(w, GLFW_KEY_W) == GLFW_PRESS) {
    dummy_obj.Position += vec2(0, -10);
  }
  if (glfwGetKey(w, GLFW_KEY_S) == GLFW_PRESS) {
    dummy_obj.Position += vec2(0, 10);
  }
  if (glfwGetKey(w, GLFW_KEY_D) == GLFW_PRESS) {
    dummy_obj.Position += vec2(10, 0);
  }
  if (glfwGetKey(w, GLFW_KEY_A) == GLFW_PRESS) {
    dummy_obj.Position += vec2(-10, 0);
  }
}
}  // namespace

class WINUT : public testing::Test {
 public:
  static void SetUpTestCase() { config.LoadConfig("winut.json"); }
  static void TearDownTestCase() {}
  void        SetUp() override {}
  void        TearDown() override {}

  static FlatConfigurator config;  // 配置读取
};
FlatConfigurator WINUT::config;

TEST_F(WINUT, WindowTest) {
  Window w(SCREEN_WIDTH, SCREEN_HEIGHT, "windowtest");
  w.SetCursorInvisble(true);
  w.SetCursorPosCallback(Pos);
  w.SetMouseBtnCallback(Btn);
  w.SetScrollCallback(Pos);
  w.SetKeyboardCallback(Key);
  while (!w.ShouldClose()) {
    w.Update();
  }
  int wd, hi;
  w.GetWindowSize(&wd, &hi);
  cout << format("width=%d, height=%d") % wd % hi << endl;
}

TEST_F(WINUT, FrameBufferTest) {
  Window w(800, 600, "framebuffertest");

  // 创建一个新的帧缓冲
  auto color_attachment = std::shared_ptr<ColorAttachment>(
      new TextureColorAttachment(SCREEN_WIDTH, SCREEN_HEIGHT));
  Framebuffer fb;
  fb.Attach(color_attachment);
  fb.Bind();

  DefaultFramebufferColor(0, 0, 0, 0);
  while (!w.ShouldClose()) {
    ClearFramebuffer();
    w.Update();
  }
  UnbindFramebuffer();
}

TEST_F(WINUT, SpriteTest) {
  Window w(SCREEN_WIDTH, SCREEN_HEIGHT, "spritetest");
  w.SetKeyboardCallback(ProcessInputCam);
  DefaultFramebufferColor(0, 0, 0, 0);
  SpriteRender render(g_camera);

  std::shared_ptr<Texture2D> sprite(new Texture2D());
  sprite->LoadImage("texture/weapons.png");
  g_camera->MoveCentral(vec2(450, 350));
  render.SetTextureCoordAbs(vec2(512, 1024), vec2(136, 676), vec2(18, 36));
  while (!w.ShouldClose()) {
    ClearFramebuffer();
    render.DrawSprite(sprite, vec2(400, 300), vec2(180, 360));
    w.Update();
  }
}

TEST_F(WINUT, FontTest) {
  Window w(SCREEN_WIDTH, SCREEN_HEIGHT, "fonttest");
  w.SetKeyboardCallback(ProcessInputCam);
  DefaultFramebufferColor(0, 0, 0, 0);
  Font f(g_camera);
  f.Load("/Users/lambda/Library/Fonts/Minecraft.ttf");
  g_camera->MoveCentral(vec2(450, 350));
  while (!w.ShouldClose()) {
    ClearFramebuffer();
    f.Draw("hello world", vec2(400, 300), vec3(1, 0, 0));
    w.Update();
  }
}

TEST_F(WINUT, ParticleTest) {
  Window w(SCREEN_WIDTH, SCREEN_HEIGHT, "particletest");
  w.SetKeyboardCallback(ProcessInputObj);
  DefaultFramebufferColor(0, 0, 0, 0);
  std::shared_ptr<SpriteRender> render(new SpriteRender(g_camera));
  std::shared_ptr<Texture2D>    sprite(new Texture2D());
  sprite->LoadImage("texture/weapons.png");
  SimpleParticleRender part(render, sprite, PARTICLE_AMOUNT);
  part.SetDrawRange(vec2(136, 676), vec2(18, 36));
  DefaultParticleGenerator gene(vec2(10, 20), 8.0f, vec2(5));
  dummy_obj.Position = vec2(395, 290);

  double prev = Now<>();
  while (!w.ShouldClose()) {
    double curr       = Now<>();
    double delta_time = curr - prev;
    ClearFramebuffer();
    part.Update(delta_time, gene(dummy_obj.Position, vec2(0, 200)),
                config.GetValue<int>("particle_gene_num"));
    part.Draw();
    w.Update();
    prev = curr;
  }
}
