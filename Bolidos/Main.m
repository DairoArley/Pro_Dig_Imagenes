%%%%%%%%%%%%%%%%%%%%%%% Universidad de Antioquia %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% Procesamiento digital de Imágenes %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% Semestre 2018 - 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% Dairo García Vergara %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% Fernando Areiza %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BOLIDOS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vid = videoinput('winvideo', 1, 'YUY2_640x480');    %Activar la camara
set(vid, 'FramesPerTrigger', Inf);                  % Configurar las propiedades del objeto de video
set(vid, 'ReturnedColorspace', 'rgb')               % Configurar las propiedades del objeto de video
vid.FrameGrabInterval = 5;                          % Configurar las propiedades del objeto de video
start(vid)                                          %Iniciar la adquisición de video
arrayPoliceX = [];                                  %matriz de posición x
arrayPoliceY = [];                                  %matriz de posición y
visible = [];                                       %Visibilidad 1 si es visible 0 si no
[y,Fs] = audioread('music.mp3');                    %cargar audio
sound(y,Fs);                                        %reproducir audio
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Inicialización de datos%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
secondsApaPol=10;                       %Bandera que controlará la aparición de los carros cada 10 segundos
ind=0;                                  %Indice que controlará la cantidad de carros pilicias
ban2=true;                              %Bandera que controlará si el carro ha cilsionado false, sino true
punt=0;                                 %Donde se almacenará el puntaje ontenido por el jugador
ban3=1;                                 %Bandera que controlará el movimiento de la carretera

while(vid.FramesAcquired<=400)          % Configurar el ciclo que pare después de adquirir 10 cuadros por segundo      
    data = getsnapshot(vid);            % Obtener la captura del cuadro actual  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%% Para seguir el objeto rojo tiempo real, debemos sustraer el %%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%% componente rojo, de la imagen en la escala de grises para extraer el %%%
    %%%%%%%%%%%%%%%%%%% componente rojo en la imagen %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    diff_im = imsubtract(data(:,:,1), rgb2gray(data)); 
    diff_im = medfilt2(diff_im, [3 3]);                 %Se usa un filtro mediano para filtrar el ruido  
    diff_im = imbinarize(diff_im,0.18);                 % Se binariza la imagen de escala de grises     
    diff_im = bwareaopen(diff_im,300);                  % Se remueven todos los pixeles menores a 300px      
    bw = bwlabel(diff_im, 8);                           % Se etiqueta todos los componentes conectados 
                                                        % en la imagen y se guardan bw                                                    
    stats = regionprops(bw, 'BoundingBox', 'Centroid'); % se obtiene el centro de masa y el resctagulo
                                                        % que encierra el objeto
    imshow(data)                                        % Mostrar la imagen   
    hold on                                             %Se mantiene el contenido de la figura
    rectangle('Position',[120 30 400 420], 'EdgeColor','w', 'LineWidth',5)                  %Dibujar recuadro grande 
    rectangle('Position',[525 30 120 420],'FaceColor','w', 'EdgeColor','w','LineWidth',3);  %recuadros laterales
    rectangle('Position',[0 30 120 420],'FaceColor','w', 'EdgeColor','w','LineWidth',3);    %recuadros laterales
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%% Esto es para graficar toda la interacción %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for object = 1:length(stats)
        bc = stats(object).Centroid;            %Se obtine la posición del objecto
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%% Dibujar linea de carretera %%%%%%%%%%%%%%%%%%%
        ban3=drawHighway(ban3,ban2);            
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%Variables del carro posición y tamaño%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ban2 == true                     % el condicional if se valida si el carro no ha colisionado
            %%%%%%%%%%%%%%%%%%  Dibujar puntaje %%%%%%%%%%%%%%%%%%%%%%%%%%%%       
            text(530, 40, 'Tu puntaje es', 'Color', 'b', 'FontSize', 13);
            text(530, 70, num2str(punt), 'Color', 'b', 'FontSize', 16);
            xcar = bc(1);
            ycar = 330;
        else
            text(530, 120, 'Puntaje final', 'Color', 'b', 'FontSize', 13);
            text(530, 160, num2str(punt), 'Color', 'b', 'FontSize', 16);
        end       
        anchoCarro = 40;
        largoCarro = 60;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Dibujar carro  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
        rectangle('Position',[xcar ycar anchoCarro largoCarro],'FaceColor',[1 1 0],'EdgeColor', ...
            'k','LineWidth',1, 'Curvature',[0.5,1]);
        rectangle('Position',[xcar-5 ycar+10 10 15],'FaceColor',[0 0 0],'EdgeColor', ...
            'k','LineWidth',1, 'Curvature',[0.5,1]);
        rectangle('Position',[xcar+anchoCarro-5 ycar+10 10 15],'FaceColor',[0 0 0],'EdgeColor', ...
            'k','LineWidth',1, 'Curvature',[0.5,1]);
        rectangle('Position',[xcar-5 ycar+40 10 15],'FaceColor',[0 0 0],'EdgeColor', ...
            'k','LineWidth',1, 'Curvature',[0.5,1]);
        rectangle('Position',[xcar+anchoCarro-5 ycar+40 10 15],'FaceColor',[0 0 0],'EdgeColor', ...
            'k','LineWidth',1, 'Curvature',[0.5,1]);
        
        
        
        
        %%%%%%%%%%%Se genera un carro policia aleatorio haciendo uso de la función%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%generateObs() y se almacena cada 5 segundos%%%%%%%%%%%%%%%%%%%%%%%
        if mod(secondsApaPol,10)==0
            num = generateObs();
            ind=ind+1;
            arrayPoliceX(ind)=num;
            arrayPoliceY(ind)=30;
            visible(end+1)=1;
            secondsApaPol=1;
        else 
            secondsApaPol=secondsApaPol+1;
        end
        
        %%%%%%%%%%%%%%%%%%%%% Dibujar carros policias %%%%%%%%%%%%%%%%%%%%
        for indice=1:length(arrayPoliceX)
            if arrayPoliceY(indice) > 390 && visible(indice)==1
                visible(indice) = 0;
                if ban2==true;
                    punt=punt+3; 
                end
            end
            if visible(indice) == 1 || visible(indice) == 2
                rectangle('Position',[arrayPoliceX(indice) arrayPoliceY(indice) 40 60],'FaceColor', ...
                    [0 0 1],'EdgeColor','k','LineWidth',1, 'Curvature',[0.5,1])
                rectangle('Position',[arrayPoliceX(indice)-5 arrayPoliceY(indice)+10 10 15],'FaceColor',[0 0 0],...
                    'EdgeColor', 'k','LineWidth',1, 'Curvature',[0.5,1]);
                rectangle('Position',[arrayPoliceX(indice)+anchoCarro-5 arrayPoliceY(indice)+10 10 15],...
                    'FaceColor',[0 0 0],'EdgeColor', 'k','LineWidth',1, 'Curvature',[0.5,1]);
                rectangle('Position',[arrayPoliceX(indice)-5 arrayPoliceY(indice)+40 10 15],'FaceColor',...
                    [0 0 0],'EdgeColor', 'k','LineWidth',1, 'Curvature',[0.5,1]);
                rectangle('Position',[arrayPoliceX(indice)+anchoCarro-5 arrayPoliceY(indice)+40 10 15],...
                    'FaceColor',[0 0 0],'EdgeColor', 'k','LineWidth',1, 'Curvature',[0.5,1]);
            end
        end
        
        %%%%%%%%%%%%%%%%%%%% Simular el movimiento de los carros %%%%%%%%%%%%%%%%%%%%%%
        for indice=1:length(arrayPoliceX)
            if visible(indice) == 1
                arrayPoliceY(indice) = arrayPoliceY(indice)+15;
            end           
        end        
        
        %%%%%%%%%%%%%%%%%%% Chocar contra Contra los carros policias %%%%%%%%%%%%%%%%%%
        for indice=1:length(arrayPoliceX)
            if visible(indice) == 1
                police = [arrayPoliceX(indice) arrayPoliceY(indice) anchoCarro largoCarro];
                car = [xcar ycar anchoCarro largoCarro];
                %%%%%%%%%%%%%%%%%%% Si se sobreponen las areas, tienen la misma posición,
                %%%%%%%%%%%%%%%%%%% colisionan            
                if bboxOverlapRatio(car, police) > 0
                    rectangle('Position',[xcar ycar-30 40 40],'FaceColor', ...
                    [1 0 0],'EdgeColor','r','LineWidth',3, 'Curvature',[1,1]); 
                    [y,Fs] = audioread('crash.mp3'); 
                    sound(y,Fs);
                    ban2=false;
                    visible(indice)=2;                
                end
            end           
        end           
    end      
    hold off                                %Se habilita el borrado del contenido de la figura
end
stop(vid);                                  %Parar la adquisición del video
flushdata(vid);                             %Vacíe todos los datos de imagen almacenados en el búfer de memoria
clear all                                   %Limpiar todasa las variables

%%%%%%%%%%%%%%%%%% Función para generar los carros policias de manera aleatoria %%%%%%%%%%%%%%%%%%%
function [num] = generateObs()
    st = [150 190 230 270 310 350];
    indice=length(st);
    r = randi([1 indice],1,1);
    num = st(r(1)); 
end
%%%%%%%%%%%%%%%%% Dibujar lineas de Carretera %%%%%%%%%%%%%%%%
function [ban] = drawHighway(ban, ban2)
    one=[30 60 90 120 150 180 210 240 270 300 330 360 390 420];
    if ban2==false
        for i=1:length(one)
            rectangle('Position',[310 one(i) 10 20], 'EdgeColor','w', 'FaceColor', 'w', 'LineWidth',1)            
        end
    else                            %Simular movimiento de la carretera
        for i=1:length(one)
            if ban==1
                rectangle('Position',[310 one(i) 10 20], 'EdgeColor','w', 'FaceColor', 'w', 'LineWidth',1)
                ban=2;
            elseif ban==2            
                rectangle('Position',[310 one(i)+10 10 20], 'EdgeColor','w', 'FaceColor', 'w', 'LineWidth',1)
                ban=3;
            else 
                rectangle('Position',[310 one(i)+20 10 20], 'EdgeColor','w', 'FaceColor', 'w', 'LineWidth',1)
                ban=1;
            end       
        end    
    end
        
end
    



