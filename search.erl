-module(search).

-compile(export_all).
-export([greedy/0]).


%%Ejecuta el algoritmo greedy con los valores inciales.
greedy() ->
	board ! {get_neighbors, self()},
	receive
	{[], _} ->
		io:format("No hay camino posible!~n");
	{Neighbors, Heuristics} ->
		greedy_search(Neighbors, Heuristics)
	end.

%%Implementacion del algoritmo greedy con backtracking.
greedy_search(FringeN, FringeH) ->
	case FringeN of
	[] -> %%En caso de que la frontera este vacia, entonces no hay camino posible.
		io:format("No hay camino posible!!~n");
	_ -> %%En cualquier otro caso sigue buscando.
		Min = lists:min(FringeH),
		Index = index_of(Min, FringeH),
		NewPos = {R,C} = lists:nth(Index, FringeN),
		NewFringeN = lists:delete({R,C}, FringeN),
		NewFringeH = lists:delete(Min, FringeH),
		board ! {get_finish, self()},
		receive
		X ->
			case X of
			NewPos -> %%En caso de que el punto final este en los vecinos termina!
				io:format("Fin~n");
			_->  %%En Cualquier otro caso sigue buscando.
				board ! {move, NewPos},
				wait(1),
				board ! {get_neighbors, self()},
				receive
					{[], _} -> %%Si no tiene vecinos entonces busque de nuevo en la frontera.
						greedy_search(NewFringeN, NewFringeH);
					{Neighbors, Heuristics} -> %%Si tiene vecinos agreguelos a la frontera y busque de nuevo.
						NewFringe3N = lists:append(NewFringeN, Neighbors),
						NewFringe3H = lists:append(NewFringeH, Heuristics),
						greedy_search(NewFringe3N, NewFringe3H)
				end
			end
		end
	end.
	

%%retorna el numero de un elemento dentro de una lista.
index_of(Item, List) -> index_of(Item, List, 1).
index_of(Item, [Item|_], Index) -> Index;
index_of(Item, [_|Tl], Index) -> index_of(Item, Tl, Index+1).

%%Espera una cantidad de segundos.
wait(Sec) -> 
	receive
	after (1000 * Sec) -> ok
	end.
