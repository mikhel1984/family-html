============= О программе =============
make_tree - программа на Lua, которая генерирует html-страницы с семейной биографией.


============ Открыть html =============
Корневой страницей является файл family.html, дважды щёлкните по нему.


======= Генерация/обновление ==========
Для обновления "сайта" выполните комадну

lua make_tree.lua

В Windows можно запустить файл сценария
"обновить.bat"
При этом будет использовать интерпретатор Lua, лежащий в папке make_tree.


====== Добавление члена семьи ==========
Страницы html формируются на основе одноимённых файлов с расширением .tree, которые лежат в папке family_files. Можно создать такой файл самостоятельно, но проще скопировать макет с именем maket.tree из папки make_tree. После копирования файл нужно переименовать, при этом новое название должно быть записано латиницей. Удобнее всего использовать имя человека. После добавления tree-файла в family_files и его переименования, заполните содержимое файла, как описано в следующем пункте.


======== Заполнение данных =============
В tree-файле можно использовать строчные комментарии, начинающиеся со знака "--" (как принято в Lua).

Файл данных структурируется с помощью тегов, помещенных в фигурные скобки. Часть тегов обозначают разделы и не требуют после себя текста (Образование, Армия, Работа, Адрес, Дополнительно, Галерея), остальные могут сопровождаться текстом. Расположение текста относительно тега (справа, снизу, пробелы и пустые строки) роли не играет.

Единственный ОБЯЗАТЕЛЬНЫЙ К ЗАПОЛНЕНИЮ тег - {ФИО}, он должен идти ПЕРВЫМ! (остальные разделы могут следовать в любом порядке) Имя человека является его идентификатором, по-этому если встречаются полные тёзки, кому-то придётся поменять имя, например, добавив в конце порядковый номер.

Общая информация о человеке следует за {ФИО} и включает в себя теги
{Фото} - портрет, здесь указывается название файла в family_files/img.
{Описание} - какие-то данные, например, годы жизни
{Ссылка} - можно добавить ссылку с соцсети.

Данные о семье.
{Родители} - список родителей, разделителем является перенос строк.
{Брак} - имя супруга/супруги.
{Дети} - список детей, разделителем также является перенос строк.
{Описание} - при желании здесь можно добавить какой-то коментарий.
Если браков было несколько, можно повторять структуру Брак/Дети несколько раз. Имена должны указываться в именительном падеже и именно так, как они записаны в соответствующих tree-файлах (если таковые были созданы).

Каждый из разделов биографии начинается с тега, который объявляет данный раздел. Затем следуют теги
{Где} - место, будет выделено жирным
{Когда} - время, будет выделено курсивом
{Описание} - какие-то подробности
Также можно добавить:
{Ссылка} - ссылка на интернет ресурс
{Фото} - название файла, который должен лежать в папке family_files/img.
Однако, для фотографий предусмотрен специальный раздел "Галерея".


============= Оформление =================
Структура html-файла формируется на основе шаблона template.html из папки make_tree, описание стилей - family_files/panels.css. Т.е. изменяя эти файлы можно добиться изменения внешнего вида "сайта".

