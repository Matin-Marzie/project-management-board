from django.shortcuts import render

# Create your views here.
from django.shortcuts import render

# Create your views here.
from django.http import HttpResponse
from django.views.decorators.http import require_GET

@require_GET
def tasks_list(request):
    return HttpResponse("tasks Get page")