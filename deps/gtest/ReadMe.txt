�������в���ѡ��
һ����ִ�еĲ��԰������й��ˣ�֧��ͨ���

--gtest_filter

TEST(testsuitname, testcasename)
TEST_F(testsuitname, testcasename)

?    �����ַ�
*    �����ַ�
-    �ų����磬-a ��ʾ����a
:    ȡ���磬a:b ��ʾa��b

������������ӣ�
./gtestdemo0 
û��ָ������������������������

./gtestdemo0 --gtest_filter=* 
ʹ��ͨ���*����ʾ������������

./gtestdemo0 --gtest_filter=googletest1.* 
��������testsuitname Ϊ googletest1����������

./gtestdemo0 --gtest_filter=googletest1.*:googletest11.* 
��������testsuitname Ϊgoogletest1��googletest11����������

./gtestdemo0 --gtest_filter=googletest11.aaa* 
������testsuitname Ϊgoogletest11����testcasenameǰ��������ĸΪaaa��ƥ�����������

./gtestdemo0 --gtest_filter=googletest11.aaa*-googletest11.aaabbb 
�������������������������ǳ���googletest11.aaabbb�������




���������Խ�������һ��xml��
--gtest_output=xml[:DIRECTORY_PATH\|:FILE_PATH]

--gtest_output=xml
��ָ�����·��ʱ��Ĭ��Ϊ��ǰ·�����ļ���Ϊtest_detail.xml

--gtest_output=xml:d:\ 
ָ�������ĳ��Ŀ¼��test_detail.xml�ļ���

--gtest_output=xml:d:\foo.xml
ָ�������d:\foo.xml




���������ο����ϴ�����

���в�����ʹ�ã��뿴

http://www.cnblogs.com/coderzh/archive/2009/04/10/1432789.html


����������setup��teardown����Ϊ��ʹ���뿴

http://www.cnblogs.com/coderzh/archive/2009/04/06/1430396.html


���ֶ����뿴

http://www.cnblogs.com/coderzh/archive/2009/04/06/1430364.html
