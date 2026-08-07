#include <coroutine>
#include <cstdio>

class Task {
public:
  struct promise_type;
  using Handle = std::coroutine_handle<promise_type>;

  struct promise_type {
    Task get_return_object() noexcept {
      return Task(Handle::from_promise(*this));
    }

    std::suspend_never initial_suspend() noexcept {
      return {};
    }

    std::suspend_always final_suspend() noexcept {
      return {};
    }

    void return_void() noexcept {}
    void unhandled_exception() noexcept {}
  };

  explicit Task(Handle handle) noexcept : handle_(handle) {}

  Task(const Task &) = delete;
  Task &operator=(const Task &) = delete;

  Task(Task &&other) noexcept : handle_(other.handle_) {
    other.handle_ = nullptr;
  }

  Task &operator=(Task &&other) noexcept {
    if (this != &other) {
      Destroy();
      handle_ = other.handle_;
      other.handle_ = nullptr;
    }
    return *this;
  }

  ~Task() {
    Destroy();
  }

  void Resume() const {
    if (handle_ && !handle_.done()) {
      handle_.resume();
    }
  }

private:
  void Destroy() noexcept {
    if (handle_) {
      handle_.destroy();
      handle_ = nullptr;
    }
  }

  Handle handle_;
};

Task RunCoroutine() {
  std::puts("coroutine: entered");
  co_await std::suspend_always{};
  std::puts("coroutine: resumed");
}

int main() {
  std::puts("coroutine validation test: start");
  Task task = RunCoroutine();
  task.Resume();
  std::puts("coroutine validation test: ok");
  return 0;
}
