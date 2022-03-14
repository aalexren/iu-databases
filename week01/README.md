a.chernitsa@innopolis.university – Artem Chernitsa, B20-02

Team members also:  
Khabib Khaysadykov k.khaysadykov@innopolis.university  
Adela Krylova a.krylova@innopolis.university  
Artyom Murashko ar.murashko@innopolis.university  
Iskander Nafikov i.nafikov@innopolis.university  

From client we understood that:
   + each Artist should have ID key attribute 
   + Album should be identified based on its Artist and Name
   + Track should be identified based on its Album and Name  

Finally it means, that this is weak entities and relations between them. That's why Name attribute of Track is partial key attribute and the Name of Album too.  
Besides, there is only strict condition that Track can't exist without Album. Every Artist can have a lot of Albums.

![](scheme.jpeg)
