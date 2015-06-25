SRC_DIR=../src
TEST_DIR=.
LIB_DIR=.
TEST_LIB_DIR=.

TARGET=
HEADERS=${wildcard $(SRC_DIR)/*.h}
SRCS=${wildcard $(SRC_DIR)/*.c}
OBJS=$(SRCS:$(SRC_DIR)/%.c=$(LIB_DIR)/%.o)

TEST_TARGET=$(TEST_LIB_DIR)/example.so
TEST_SRCS=${wildcard $(TEST_DIR)/*.c}
TEST_OBJS=test_example.o

CUTTER_FLAGS=${shell pkg-config --cflags cutter}
CUTTER_LIBS =${shell pkg-config --libs   cutter}

OPTIM  = -g -O0 -Wall
CFLAGS = -std=gnu99 ${OPTIM} -DUSE_TRANSACTION -DLinux

all: $(TARGET) $(TEST_TARGET)

test: $(TEST_TARGET)

run: $(TEST_TARGET)
	cutter $(TEST_LIB_DIR)

$(TARGET): $(OBJS)
	gcc $(CFLAGS) $(OBJS) -o $@

$(LIB_DIR)/%.o: $(SRC_DIR)/%.c $(HEADERS)
	gcc $(CFLAGS) -O -fPIC -c $< -o $@

$(TEST_TARGET): $(TEST_OBJS) $(OBJS)
	gcc $(CFLAGS) -shared $(TEST_OBJS) $(OBJS) $(CUTTER_LIBS) -o $@

$(TEST_LIB_DIR)/%.o: $(TEST_DIR)/%.c $(HEADERS)
	gcc $(CFLAGS) -O -fPIC -c $< -I$(SRC_DIR) $(CUTTER_FLAGS) -o $@

clean:
	find . -regex ".*\.s?o" | xargs rm -f
