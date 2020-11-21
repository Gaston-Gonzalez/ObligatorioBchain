Contrato AnimalToken

Tokens:
Animal



Sincronización con Ganache

mint:
Función de constructor del token. Se le agrega pasa por parámetro la información que se conoce del animal en ese momento. Solo la pueden ejecutar cuentas que estén reconocidas como granjas




updateAnimalWeight:

Permite actualizar el peso de un animal. Se le pasa por parámetro el id del token que le corresponde, y el nuevo peso a registrar.
El método devuelve: “<tokenId> weight changed from <peso anterior> kg to <peso nuevo> kg
Se crea además dentro del animal un evento que registra este cambio. 

slaughter:

Recibe el id de un token correspondiente a un animal. Tras verificar que ese token está registrado (en caso contrario se notifica por la consola) y que la cuenta que está ejecutando el método es la dueña de ese token u otra a la que la cuenta el dueño le dio permiso, en caso contrario también se interrumpe el flujo de la operación. Si se cumple con las condiciones mencionadas, aparece un mensaje indicando que el animal del token indicado ha sido faenado o ha muerto.
Se agrega un último evento dentro del token, antes de ser eliminado.


transferFrom:

Recibe por parámetro dos direcciones de granjas diferentes y un id de token. En caso de que este último corresponda a un token existente en la blockchain, y de que la cuenta que está ejecutando el método es la dueña del token u autorizada por esta, se efectúa la transferencia desde la primera cuenta a la segunda, y se muestra un mensaje en pantalla indicándolo. Si por alguna razón la transferencia no debe realizarse, también se indica al usuario. Se usa para transferir ganado entre granjas.

changeFarmLocation

Permite mover un token dentro de una misma granja. Recibe como parámetro address de salida, address de entrada y caravana.
***_*Es necesario correr la función myApprove de la siguiente manera*_***

myApprove
Da permiso a la granja de manejar un token que esté en una farm location. **Tiene que tener como msg.sender la farmLocation** recibe como parámetros el address de la granja y la caravana del token transferido anteriorm.emte


Contrato Accounts

(Se puede levantar igual que el contrato anterior)

Se tienen 2 tipos de cuentas:
Granjas
Espacios dentro de granjas:

El contrato permite crear cuentas que sean de cualquiera de estos 2 tipos, y posee métodos para saber si una cuenta es de cualquiera de esos 2 tipos. No pueden ser de ambos tipos a la vez. A la primera cuenta del contrato se le da un atributo de administrador, que permite crear las demás cuentas

createFarm
	Se usa para darle rol de granja a una adress. Solo el admin (primera cuenta creada) puede realizar esta operación

createFarmLocation
Crea una cuenta de tipo “espacio dentro de granja”. Necesita que la cuenta que lo ejecute sea una farm

