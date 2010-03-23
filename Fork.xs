#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <pthread.h>

char *nothing[] = { NULL };

void hook_fork_prepare(void){
  call_argv("Hook::Fork::run_before_hooks", G_DISCARD, nothing);
}

void hook_fork_parent(void){
  call_argv("Hook::Fork::run_parent_hooks", G_DISCARD, nothing);
}

void hook_fork_child(void){
  call_argv("Hook::Fork::run_child_hooks", G_DISCARD, nothing);
}


MODULE = Hook::Fork		PACKAGE = Hook::Fork

void
init()
  CODE:
    pthread_atfork(&hook_fork_prepare, &hook_fork_parent, &hook_fork_child);
