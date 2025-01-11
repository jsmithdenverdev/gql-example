package service

type TodoService struct {
}

func NewTodoService() *TodoService {
	return &TodoService{}
}

func (t *TodoService) GetTodo() string {
	return "todo"
}
