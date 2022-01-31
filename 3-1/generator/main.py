from random import randint, seed
from tqdm import tqdm

STUDENTS_CNT = 10000000
COURSES_CNT = 10

review_file = open('review_data.txt', 'w')
students_file = open('std_data.txt', 'w')

names = []

courses_list = []


def getRandomName():
    return f"{names[randint(0, len(names) - 1)]}"


acv = ["Староста группы", "Победитель ЧГК", "Мастер спорта", "Идеальная посещаемость", "Почётный донор России",
       "Грандмастер", "Достижения в волонтёрстве"]

class RandomStudent():
    def getAchivments(self):
        acv_cnt = randint(0, 2)

        res = "{}"

        if acv_cnt == 2:
            a = randint(0, len(acv) - 1)
            b = randint(0, len(acv) - 1)

            if (a == b):
                b = (b + 1) % len(acv)


            res = f'{{{acv[a]}, {acv[b]}}}'

        elif acv_cnt == 1:
            res = f'{{{acv[randint(0, len(acv) - 1)]}}}'

        return res

    def getMarks(self):
        marks = []
        for i in range(len(courses_list)):
            marks.append(randint(3, 5))

        return f'{{"{courses_list[0].name}":{marks[0]},' \
               f'"{courses_list[1].name}":{marks[1]},' \
               f'"{courses_list[2].name}":{marks[2]},' \
               f'"{courses_list[3].name}":{marks[3]},' \
               f'"{courses_list[4].name}":{marks[4]},' \
               f'"{courses_list[5].name}":{marks[5]},' \
               f'"{courses_list[6].name}":{marks[6]},' \
               f'"{courses_list[7].name}":{marks[7]},' \
               f'"{courses_list[8].name}":{marks[8]},' \
               f'"{courses_list[9].name}":{marks[9]}}}', \
               sum(marks) / len(courses_list)

    def __init__(self, idd):
        self.idd = idd
        self.name = getRandomName()
        self.acv = self.getAchivments()
        self.marks, self.avg = self.getMarks()


class Course:
    def __init__(self, idd, name, head, desc, creditss):
        self.idd = idd
        self.name = name
        self.head = head
        self.desc = desc
        self.credits = creditss

    def get_str_for_print(self):
        return f"{self.idd}/{self.name}/{self.head}/{self.credits}/{self.desc}"


reviews_texts = [
    "Мне очень понравился этот курс. Преподаватели очень отвественны и материал актуален. Хотелось бы больше подобных курсов",
    "Курс просто ужасен. Отвратительный материал.Сложный и не нужный.", "Крутой курс!!!!!!!!!",
    "Описать этот курс можно всего лишь двумя словами: отвратительно и отвратительно",
    "Курс, конечно не плохой, но только для саморазвития. Если захочешь вникнуть в тему, то материала однозначно недостаточно",
    "Простой и понятный курс.",
    "Мне понравился этот курс. Хочу сказать спасибо всему преподавательнскому составу",
    "По сравнению с другими курсами в университете этот просто ужасен!",
    "Нет текста отзыва", "Нет текста отзыва", "Нет текста отзыва", "Нет текста отзыва", "Нет текста отзыва",
    "Нет текста отзыва", "Нет текста отзыва", "Нет текста отзыва", "Нет текста отзыва", "Нет текста отзыва"
]

suggestions_texts = [
    "Необходимо купить лабароторное оборудование для курса.",
    "Этому курсу нужны свежие умы! Пусть студенты выступают в начале каждой пары. Будет интерсно их послушать",
    "Нужно сократить часы для курса в двое. Слишком много воды",
    "Хотелось бы на последнем занятии послушать инноваторов ведущих это направление в будующее",
    "Нет предложений", "Нет предложений", "Нет предложений", "Нет предложений", "Нет предложений",
    "Нет предложений", "Нет предложений", "Нет предложений"
]

marks_texts = [
    '"Понятность материала"', '"Открытность преподавателей к общению"', '"Полезность материала"',
]


class RandomReview:
    def getMarks(self):
        marks = []

        for i in range(len(marks_texts)):
            marks.append(randint(0, 10))

        return f'{{{marks_texts[0]}:{marks[0]},' \
               f'{marks_texts[1]}:{marks[1]},' \
               f'{marks_texts[2]}:{marks[2]}}}', sum(marks) / len(marks_texts)

    def __init__(self):
        self.review_text = reviews_texts[randint(0, len(reviews_texts) - 1)]
        self.marks, self.avg_mark = self.getMarks()
        self.suggestions = suggestions_texts[randint(0, len(suggestions_texts) - 1)]
        self.review_date = f'{2020 + randint(0, 1)}_05_{20 + randint(0, 10)}'


def make_and_print_courses():
    l = ['Математический анализ', 'Машинное обучение', 'Структуры данных', 'Дискретная математика',
         'Электродинамика',
         'Культура речи', 'Ораторское искусство', 'Физическая культура', 'Комплексный анализ',
         'Практикум на ЭВМ']

    f = open("courses_desc.txt")
    desc = f.read().splitlines()
    f.close()

    for i in range(len(l)):
        courses_list.append(Course(i, l[i], getRandomName(), desc[i], randint(1, 7)))

    course = open('course_data.txt', 'w')

    for i in range(len(courses_list)):
        course.write(f'{courses_list[i].idd}/{courses_list[i].name}/{courses_list[i].head}/{courses_list[i].credits}/'
                     f'{courses_list[i].desc}\n')

    course.close()


def read_names():
    global names

    f = open("names.txt", "r")

    names = f.read().splitlines()

    f.close()



def main():
    for i in tqdm(range(STUDENTS_CNT), desc=f"Students: "):
        s = RandomStudent(i)
        students_file.write(f'{s.idd}/{s.name}/{s.marks}/{s.avg}/{s.acv}\n')
        for j in range(len(courses_list)):
            r = RandomReview()

            review_file.write(f'{i * 10 + j}/{s.idd}/{courses_list[j].idd}/{courses_list[j].name}/{r.review_text}/'
                              f'{r.marks}/{r.avg_mark}/{r.suggestions}/{r.review_date}/{s.avg}/{s.name}/'
                              f'{courses_list[j].head}/{courses_list[j].credits}\n')

    review_file.close()
    students_file.close()


if __name__ == "__main__":
    seed()
    read_names()
    make_and_print_courses()
    main()

