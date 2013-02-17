unit uTIMView;

interface

uses
  dglOpenGL, Windows, Controls, uTIM;

type
  PControl = ^TWinControl;

implementation

var
  mDC: HDC;
  mRC: HGLRC;
  Tex: GLuint;

procedure OpenGLFinish(ViewTo: PControl);
begin
  DeactivateRenderingContext;
  wglDeleteContext(mRC);
  ReleaseDC(ViewTo^.Handle, mDC);
end;

procedure GLSetup;
begin
  glClearColor(0.0, 0.0, 0.0, 0.0);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  SwapBuffers(mDC);
end;

procedure OpenGLInit(ViewTo: PControl);
begin
  if not InitOpenGL then
    Exit;

  mDC := GetDC(ViewTo^.handle);
  mRC := CreateRenderingContext(mDC, [opDoubleBuffered], 32, 24, 0, 0, 0, 0);
  ActivateRenderingContext(mDC, mRC);

  GLSetup;
end;

procedure Rendering;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glLoadIdentity();
  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D, tex);
  glBegin(GL_QUADS);
  glTexCoord2f(0, 0);
  glVertex2f(-1, -1);
  glTexCoord2f(0, -1);
  glVertex2f(-1, 1);
  glTexCoord2f(1, -1);
  glVertex2f(1, 1);
  glTexCoord2f(1, 0);
  glVertex2f(1, -1);
  glEnd;

  glDisable(GL_TEXTURE_2D);
  SwapBuffers(mDC);
end;

procedure SetViewPort(ViewTo: PControl);
begin
  glViewport(0, 0, ViewTo.ClientWidth, ViewTo.ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluPerspective(0.0, ViewTo.ClientWidth / ViewTo.ClientHeight, 1.0, 100.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  Rendering;
end;

procedure ViewTim(pnlView: PControl; TIM: PTIM);
begin
  OpenGLInit(pnlView);
  SetViewPort(pnlView);

  

  OpenGLFinish(pnlView);
end;

end.
