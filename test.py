class ClassMates:
    def __init__(self):
        self.students = []
    
    def addMates(self, mate):
        print("传入了参数: "+mate)
        self.students.append(mate)
    
    def clear(self):
        self.students = []
    
    def getFisrtMate()

# 【】表示概念、术语。
# 这里我定义了一个【类型】 ClassMates, 它包含着两个【方法】 addMates() 和 clear() 和一个 【字段】(也就是变量)
# addMates() 的行为是向 students 添加一个同学
# clear() 的行为是将 students 清空


if __name__ == "__main__":
    matesA = ClassMates()
    matesB = ClassMates()
    # 这里定义了类型 ClassMates 的 2个 【对象】

    # 下面是添加两个学生, 然后把他们打印出来
    matesA.addMates("菌子")
    matesA.addMates("小轩窗")
    print(matesA.students)
    # 然后我们再把它清空
    matesA.clear()
    print(matesA.students)

    # 可以看到, 类型 ClassMates 的两个方法都能被 matesA 这个对象拥有和执行
    # . 这个操作符实际上就是把对象本身作为了函数(方法)第一个参数m, 也就是 self



